
import 'dart:async';
import 'dart:collection';

import 'package:pritt_common/interface.dart' hide Queue;
import 'package:pritt_common/retry_map.dart';
import 'package:pritt_common/worker.dart';

import 'db/schema.dart';

abstract class TaskBase {
  abstract final String id;
  TaskStatus status;

  TaskBase() : status = TaskStatus.queue;
}

extension Elevate<T extends TaskBase> on T {
  WorkerItem<T, K> upgrade<K>(K resource) => WorkerItem(this, resource);
}

class WorkerItem<T extends TaskBase, K> {
  final T task;
  final K resource;

  WorkerItem(this.task, this.resource);
}

/// The different modes the [TaskRunner] can run on
enum TaskRunnerMode {
  /// Every worker runs on a single task, and work cannot continue until a worker is free of all tasks
  singleTask,

  /// Workers can queue tasks and handle them, preventing the main task runner loop from blocking
  multiTask
}

/// The task runner service
///
/// This service is responsible for handling background tasks and jobs in a queue to ensure consistent latency between the processing of jobs
///
/// The task runner makes use of a Dart [Queue] for queueing tasks, which are associated with an id for identification
/// The items in the queue are just task references in order to prevent storing large data inside the task runner
///
/// Instead, an [onRetrieve] function is used for retrieving data needed for processing in the worker.
/// If [onRetrieve] returns null for a given task, the task is kept as idle and placed in a [RetryMap] bag, which is polled after a given duration,
/// specified by the [retryInterval]. If the resource is available by then, the value is stored in [eagerWorkerAssets] and then given to the task later.
///
/// > If such tasks are expensive, an optional `onCheck` function can be passed to the constructor to be called to check if a resource is available,
/// > before retrieving the resource when added back into the queue.
///
/// ## The Main Loop
/// The task runner starts a loop that goes through items in the queue one by one, waits until a [Worker] is available, and then gets the resource needed for the task before passing.
/// If resource isn't available, it goes on until it finds the first item in the queue with a resource.
/// Once a resource is gotten, the [Worker] runs. If the worker returns, the value is added to [completedTasks]. It is advised for large tasks that they should not return.
///
/// For more information on workers, check out the docs on [Worker]s.
///
/// ## Modes
/// The task runner can run in two modes: **single task mode** [TaskRunnerMode.singleTask], and **multi task mode** [TaskRunnerMode.multiTask].
/// For more info on these modes, check out the docs on [TaskRunnerMode].
///
/// ## Generics
/// The Task Runner contains generics so that it can be used for multiple kinds of resources and tasks
/// - [Task] represents the type of the task, which must extend [TaskBase]
/// - [Res] represents the type of the resource to be retrieved and combined with the [Task] to form a [WorkerItem]
/// - [Ret] represents the return of the worker, if any
///
/// -----------------------------------------------------
///
/// TODO: onCheck is only implemented in [idleTasks]. We should consider implementing this in the main loop as well
/// TODO: Complete assignment of task item statuses
/// TODO: Use [unawaited]
/// TODO: Clear out prints from code
/// TODO: ID Generation
///
class TaskRunner<Task extends TaskBase, Res extends Object, Ret> {
  static int _maximumWorkers = 2;

  final Queue<Task> queue = Queue();
  final Map<String, Ret> completedTasks = {};
  final Map<String, Res> eagerWorkerAssets = {};
  final Map<String, Worker<WorkerItem<Task, Res>, Ret>> workers = Map();
  final Duration pollInterval;
  final Duration retryInterval;
  late final RetryMap<String, Task> idleTasks;
  Completer<void> _availabilityCompleter = Completer();

  final FutureOr<Res?> Function(Task) onRetrieve;
  final FutureOr<Ret> Function(WorkerItem<Task, Res>) workAction;
  final TaskRunnerMode mode;

  bool _isActive = false;

  bool get active => _isActive;
  bool get empty => queue.isEmpty && idleTasks.isEmpty;
  bool get complete => empty && workers.values.every((w) => !w.isBusy);

  /// if [onRetrieve] returns null, then the resource associated with the queue task is not available
  TaskRunner({
    this.pollInterval = const Duration(milliseconds: 150),
    Duration? retryInterval,
    required this.onRetrieve,
    required this.workAction,
    this.mode = TaskRunnerMode.singleTask,
    FutureOr<bool> Function(Task)? onCheck,
  }) : retryInterval = retryInterval ?? Duration(milliseconds: 150) {
    idleTasks = RetryMap(retry: this.retryInterval, onRetry: (key, value) async {
      if (onCheck != null) {
        if (await onCheck(value)) {
          // add value back to queue beginning
          queue.addFirst(value);
          return true;
        } else return false;
      } else {
        final resource = await onRetrieve(value);
        if (resource != null) {
          eagerWorkerAssets[key] = resource;
          queue.addFirst(value);
          return true;
        } else return false;
      }
    });
  }


  /// Starts the task runner
  void start() async {
    _isActive = true;
    if (mode == TaskRunnerMode.singleTask) _run();
    else _runMultiTask();
  }

  /// Similar to [_run], except there is no getting next worker, and workers are added based on the ones that have the least commands
  Future<void> _runMultiTask() async {
    print('Running...');
    while (_isActive) {
      // check queue is empty or not
      if (queue.isEmpty) {
        print(idleTasks.isNotEmpty ? 'empty queue' : 'empty queue and no more tasks');
        // give back control to event loop
        await Future.delayed(pollInterval);
        continue;
      }

      // check for next worker
      final nextWorker = await _getLeastBusyWorker();

      // once next worker is active, get resource for queue
      // pop queue item
      var nextTask = queue.removeFirst();

      // get resource

      try {
        var resource = eagerWorkerAssets.containsKey(nextTask.id) ? eagerWorkerAssets[nextTask.id] : await onRetrieve(nextTask);
        while (resource == null) {
          print('set $nextTask as idle');
          // add to retry map, set as idle
          idleTasks[nextTask.id] = nextTask;
          if (queue.isNotEmpty) {
            nextTask = queue.removeFirst();
          } else {
            break;
          }
          resource = await onRetrieve(nextTask);
        }

        // delegate to worker
        if (resource != null) nextWorker.run(
            nextTask.upgrade(resource)
        ).then((v) => completedTasks[nextTask.id] = v);
      } catch (e) {
        nextTask.status = TaskStatus.fail;
      }

      await Future.delayed(pollInterval);
      print('Completed: ${completedTasks.keys}');
    }
  }



  Future<void> _run() async {
    print('Running...');
    while (_isActive) {
      // check queue is empty or not
      if (queue.isEmpty) {
        print(idleTasks.isNotEmpty ? 'empty queue' : 'empty queue and no more tasks');
        // give back control to event loop
        await Future.delayed(pollInterval);
        continue;
      }

      // check for next worker
      final nextWorker = await _getNextWorker();

      // once next worker is active, get resource for queue
      // pop queue item
      var nextTask = queue.removeFirst();

      // get resource

      try {
        var resource = eagerWorkerAssets.containsKey(nextTask.id) ? eagerWorkerAssets[nextTask.id] : await onRetrieve(nextTask);
        while (resource == null) {
          print('set $nextTask as idle');
          // add to retry map, set as idle
          idleTasks[nextTask.id] = nextTask;
          if (queue.isNotEmpty) {
            nextTask = queue.removeFirst();
          } else {
            break;
          }
          resource = await onRetrieve(nextTask);
        }

        // delegate to worker
        if (resource != null) nextWorker.run(
            nextTask.upgrade(resource)
        ).then((v) => completedTasks[nextTask.id] = v);
      } catch (e) {
        nextTask.status = TaskStatus.fail;
      }

      await Future.delayed(pollInterval);
      print('Completed: ${completedTasks.keys}');
    }
  }

  Future<Worker<WorkerItem<Task, Res>, Ret>> _getLeastBusyWorker() async {
    if (workers.length < _maximumWorkers) {
      print('Starting new worker...');
      final worker = await Worker.spawn<WorkerItem<Task, Res>, Ret>(
          work: workAction,
          onCleanup: notifyAvailability
      );
      workers[Slugid.nice().uuid()] = worker;
      // return new worker spawned
      return worker;
    }

    final sortedWorkers = workers.values.toList()..sort((a, b) => a.remainingTasks.compareTo(b.remainingTasks));
    return sortedWorkers.first;
  }

  /// Fetches the next available worker
  Future<Worker<WorkerItem<Task, Res>, Ret>> _getNextWorker() async {
    if (workers.length < _maximumWorkers) {
      print('Starting new worker...');
      final worker = await Worker.spawn<WorkerItem<Task, Res>, Ret>(
          work: workAction,
          onCleanup: notifyAvailability
      );
      workers[Slugid.nice().uuid()] = worker;
      // return new worker spawned
      return worker;
    }

    // if not, wait for worker active
    while (true) {
      final freeWorkers = workers.values.where(
            (w) => !w.isBusy,
      );

      if (freeWorkers.isNotEmpty) {
        print('Reutilizing worker...');
        return freeWorkers.first;
      }

      print("where's the worker?");

      await _availabilityCompleter.future;
    }
  }

  void notifyAvailability() {
    if (!_availabilityCompleter.isCompleted) {
      _availabilityCompleter.complete();
      _availabilityCompleter = Completer();
    }
  }

  /// Pauses the task runner runner
  void pause() {
    _isActive = false;
  }

  /// Stops the task runner runner
  void stop() {
    _isActive = false;

    // kill workers
    for (var worker in workers.values) {
      worker.close();
    }
  }

  /// Add task to task runner
  void addTask(Task task) {
    queue.addLast(task);
  }


}
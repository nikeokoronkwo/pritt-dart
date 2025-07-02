import 'dart:async';
import 'dart:collection';

import 'package:logging/logging.dart';
import 'package:pritt_common/retry_map.dart';
import 'package:pritt_common/worker.dart';
import 'package:slugid/slugid.dart';

import 'db/schema.dart';

abstract class TaskBase {
  abstract final String id;
  TaskStatus get status;
  FutureOr<void> updateStatus(TaskStatus newStatus, {String? message});
  void updateError(Object error);

  TaskBase();
}

extension Elevate<T extends TaskBase> on T {
  WorkerItem<T, K, C> upgrade<K, C extends Object>(K resource, {C? context}) =>
      WorkerItem<T, K, C>(this, resource, context: context);
}

class WorkerItem<T extends TaskBase, K, Ctx extends Object> {
  final T task;
  final K resource;
  final Ctx? context;

  WorkerItem(this.task, this.resource, {this.context});
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
/// TODO: Handling running outside the main loop
class TaskRunner<Task extends TaskBase, Res extends Object, Ret,
    Ctx extends Object> {
  final Logger? _logger;
  static final int _maximumWorkers = 2;

  /// The queue for worker/task items
  final Queue<Task> queue = Queue();

  /// A map of completed tasks with their final values indexed by task id
  final Map<String, Ret> completedTasks = {};

  /// A map of "eager" assets
  final Map<String, Res> eagerWorkerAssets = {};

  /// The context for worker items
  final Ctx? context;

  /// A map of active workers
  final Map<String, Worker<WorkerItem<Task, Res, Ctx>, Ret>> workers = {};
  final Duration pollInterval;
  final Duration retryInterval;
  late final RetryMap<String, Task> idleTasks;
  Completer<void> _availabilityCompleter = Completer();

  /// The call used to retrieve the resources for a task
  final FutureOr<Res?> Function(Task) onRetrieve;

  /// The call to check for a resource
  ///
  /// Pass this if you want a lighter call that can be called multiple times and if a call to [onRetrieve] might be expensive
  final FutureOr<bool> Function(Task)? onCheck;

  /// The action taking place in the worker
  ///
  /// NOTE: in order to function properly, the resource [Res] must be serializable and suitable for isolate work
  /// For more information, see: https://api.dart.dev/dart-isolate/SendPort/send.html
  final FutureOr<Ret> Function(WorkerItem<Task, Res, Ctx>) workAction;

  /// The mode the task runner is in
  final TaskRunnerMode mode;

  bool _isActive = false;

  bool get active => _isActive;
  bool get empty => queue.isEmpty && idleTasks.isEmpty;
  bool get complete => empty && workers.values.every((w) => !w.isBusy);

  /// if [onRetrieve] returns null, then the resource associated with the queue task is not available
  TaskRunner(
      {this.pollInterval = const Duration(milliseconds: 150),
      Duration? retryInterval,
      required this.onRetrieve,
      required this.workAction,
      this.mode = TaskRunnerMode.singleTask,
      this.onCheck,
      this.context,
      bool debug = false})
      : _logger = debug ? Logger('PRITT TASK RUNNER') : null,
        retryInterval = retryInterval ?? Duration(milliseconds: 150) {
    if (!hierarchicalLoggingEnabled) hierarchicalLoggingEnabled = true;
    _logger?.level = Level.ALL;

    _logger?.onRecord.listen((record) {
      print(
          'LOG ${record.loggerName}:: ${record.level.name}: ${record.time}: ${record.message} :: Logged at ${record.time}');
      if (record.error case final err?)
        print(
            'ERROR ${record.loggerName}:: ${record.level.name}: ${record.time}: $err');
      if (record.stackTrace case final stack?)
        print(
            'STACK TRACE ${record.loggerName}:: ${record.level.name}: ${record.time}: $stack');
    });

    _logger?.shout(
        'TEST MESSAGE: This ensures the logger is active if set active');

    idleTasks = RetryMap(
        retry: this.retryInterval,
        onRetry: (key, value) async {
          if (this.onCheck != null) {
            if (await this.onCheck!.call(value)) {
              _logger?.info('Queue item ${value.id} released from idle');

              await value.updateStatus(TaskStatus.queue);
              // add value back to queue beginning
              queue.addFirst(value);
              return true;
            } else
              return false;
          } else {
            final resource = await onRetrieve(value);
            if (resource != null) {
              _logger?.info('Queue item ${value.id} released from idle');

              eagerWorkerAssets[key] = resource;
              queue.addFirst(value);
              return true;
            } else
              return false;
          }
        });
  }

  /// Starts the task runner
  void start() async {
    _isActive = true;
    _logger?.fine('Task Runner Started');
    unawaited(_run());
  }

  Future<void> _run() async {
    while (_isActive) {
      // check queue is empty or not
      if (queue.isEmpty) {
        if (idleTasks.isNotEmpty) _logger?.info('Empty queue');

        // give back control to event loop
        await Future.delayed(pollInterval);
        continue;
      }

      // check for next worker
      final nextWorker = switch (mode) {
        TaskRunnerMode.singleTask => await _getNextWorker(),
        TaskRunnerMode.multiTask => await _getLeastBusyWorker(),
      };

      _logger?.info('Gotten new worker $nextWorker');

      // once next worker is active, get resource for queue
      // pop queue item
      var nextTask = queue.removeFirst();
      _logger?.info('Gotten task ${nextTask.id}. Awaiting resource check');

      // get resource

      try {
        Res? resource;

        if (eagerWorkerAssets.containsKey(nextTask.id)) {
          _logger?.info(
              'Task of id ${nextTask.id} contains eager resource loaded from idle task map');
          resource = eagerWorkerAssets[nextTask.id];
        } else {
          _logger?.info('Finding resource...');
          if (onCheck != null) {
            // use on check to loop
            var resourceIsAvailable = await onCheck!(nextTask);

            if (resourceIsAvailable) {
              resource = await onRetrieve(nextTask);
              if (resource == null) {
                _logger
                    ?.info('Omor: The check is true, but no resource is found');
                resourceIsAvailable = false;
              } else {
                resourceIsAvailable = true;
              }
            }

            while (!resourceIsAvailable) {
              _logger?.info('Task ${nextTask.id} is now idle');
              await nextTask.updateStatus(TaskStatus.idle);
              // add to retry map, set as idle
              idleTasks[nextTask.id] = nextTask;
              if (queue.isNotEmpty) {
                nextTask = queue.removeFirst();
              } else {
                _logger?.info('All tasks have been exhausted');
                break;
              }
              resourceIsAvailable = await onCheck!(nextTask);

              if (resourceIsAvailable) {
                resource = await onRetrieve(nextTask);
                if (resource == null) {
                  _logger?.info(
                      'Omor: The check is true, but no resource is found');
                  resourceIsAvailable = false;
                } else {
                  _logger?.fine(resource);
                  break;
                }
              }
            }

            resource ??= await onRetrieve(nextTask);
            _logger?.fine('Found resource: $resource');
          } else {
            var resource = await onRetrieve(nextTask);
            while (resource == null) {
              _logger?.info('Task ${nextTask.id} is now idle');

              await nextTask.updateStatus(TaskStatus.idle);
              // add to retry map, set as idle
              idleTasks[nextTask.id] = nextTask;
              if (queue.isNotEmpty) {
                nextTask = queue.removeFirst();
              } else {
                _logger?.info('All tasks have been exhausted');
                break;
              }
              resource = await onRetrieve(nextTask);
            }

            _logger?.fine('Found resource: $resource');
          }
        }

        _logger?.info('Resource check and delegation....');

        // delegate to worker
        if (resource != null) {
          _logger?.info('Gotten new task to execute');

          await nextTask.updateStatus(TaskStatus.pending);

          nextWorker
              .run(nextTask.upgrade(resource, context: context))
              .then((v) async {
            _logger?.fine('Task ${nextTask.id} completed successfully');
            await nextTask.updateStatus(TaskStatus.success);
            _logger?.fine('Task is now ended');
            completedTasks[nextTask.id] = v;
          }).catchError((e, stack) async {
            _logger?.severe(
                'Task of id ${nextTask.id} failed with an error', e, stack);
            nextTask.updateError(e);
            await nextTask.updateStatus(TaskStatus.fail);
          });
        }

        _logger?.info('Next loop');
      } catch (e, stackTrace) {
        // if the worker causes an error:
        _logger?.severe(
            'Task of id ${nextTask.id} contains error', e, stackTrace);
        nextTask.updateError(e);
        await nextTask.updateStatus(TaskStatus.error);
      }

      await Future.delayed(pollInterval);
    }
  }

  Future<Worker<WorkerItem<Task, Res, Ctx>, Ret>> _getLeastBusyWorker() async {
    if (workers.length < _maximumWorkers) {
      final worker = await Worker.spawn<WorkerItem<Task, Res, Ctx>, Ret>(
          work: workAction, onCleanup: notifyAvailability);
      workers[Slugid.nice().uuid()] = worker;
      // return new worker spawned
      return worker;
    }

    final sortedWorkers = workers.values.toList()
      ..sort((a, b) => a.remainingTasks.compareTo(b.remainingTasks));
    return sortedWorkers.first;
  }

  /// Fetches the next available worker
  Future<Worker<WorkerItem<Task, Res, Ctx>, Ret>> _getNextWorker() async {
    if (workers.length < _maximumWorkers) {
      final worker = await Worker.spawn<WorkerItem<Task, Res, Ctx>, Ret>(
          work: workAction, onCleanup: notifyAvailability);
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
        return freeWorkers.first;
      }

      await _availabilityCompleter.future;
    }
  }

  void notifyAvailability() {
    if (!_availabilityCompleter.isCompleted) {
      _availabilityCompleter.complete();
      _availabilityCompleter = Completer();
    }
  }

  /// Resums the task runner
  void resume() {
    if (_isActive) throw StateError('Task Manager is already active');
    idleTasks.resume();
  }

  /// Pauses the task runner
  void pause() {
    _isActive = false;
    idleTasks.pause();
  }

  /// Stops the task runner
  void stop() {
    _isActive = false;

    // stop retry client
    idleTasks.pause();

    // kill workers
    for (var worker in workers.values) {
      worker.close();
      workers.removeWhere((k, v) => v == worker);
    }
  }

  /// Add task to task runner
  void addTask(Task task) {
    queue.addLast(task);
  }
}

class WorkerException implements Exception {
  Object? cause;

  WorkerException(this.cause)
      : assert(cause is Exception || cause is Error,
            "cause must be an exception or error"),
        super();
}

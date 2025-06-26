import 'dart:async';
import 'dart:isolate';

/// A Worker
///
/// A worker is an isolate that runs a given task in an isolate thread and can be reused for running such tasks over and over again.
/// They are useful for concurrent working of queued data or multiple data which run on the same functionality
///
/// They are used in:
/// - sorting adapters: both in the CLI and Server
/// - the task queue and worker orchestration for publishing tasks on the server
///
/// Workers can handle multiple commands at once.
/// Whether they should or not highly depends on the duration of the work running, and the number of tasks.
///
/// Running workers on multitask mode is faster for longer tasks with a larger number of task items
///
/// TODO: Handle sorting adapters implementation
class Worker<P, R> {
  final SendPort _commands;
  final ReceivePort _responses;
  final void Function()? _onCleanup;
  final Map<int, Completer<R>> _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;

  /// Whether a given worker is busy or not
  bool get isBusy => _activeRequests.isNotEmpty;

  /// The number of tasks remaining before this worker no longer becomes busy
  int get remainingTasks => _activeRequests.length;

  /// Creates a new [Worker] that runs [work] on every call to [run] on the given worker
  ///
  /// If [onCleanup] is passed, once all tasks are complete, [onCleanup] is called on the tasks.
  /// It is recommended to only pass [onCleanup] if working on single task mode.
  static Future<Worker<P, R>> spawn<P, R>(
      {required FutureOr<R> Function(P) work,
      void Function()? onCleanup}) async {
    // Create a receive port and add its initial message handler
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };

    // Spawn the isolate.
    try {
      await Isolate.spawn(_startRemoteIsolate(work), (initPort.sendPort));
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    return Worker._(receivePort, sendPort, onCleanup: onCleanup);
  }

  Worker._(this._responses, this._commands, {void Function()? onCleanup})
      : _onCleanup = onCleanup {
    _responses.listen(_handleResponsesFromIsolate);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    final (int id, Object? response) = message as (int, Object?);
    final completer = _activeRequests.remove(id)!;

    if (response is RemoteError) {
      completer.completeError(response);
    } else {
      final value = response as R;
      if (_activeRequests.isEmpty) {
        _onCleanup?.call();
      }
      completer.complete(value);
    }

    if (_closed && _activeRequests.isEmpty) _responses.close();
  }

  static void _handleCommandsToIsolate<P, R>(
    ReceivePort receivePort,
    SendPort sendPort,
    FutureOr<R> Function(P) work,
  ) async {
    await for (final message in receivePort) {
      // receivePort.listen((message) async {
      if (message is WorkerTask) {
        switch (message) {
          case WorkerTask.shutdown:
            receivePort.close();
            return;
        }
      }
      final (int id, P param) = message as (int, P);
      try {
        /// TODO: We need to handle errors. They are leaking out of this despite try/catch, handleError, and Future.sync
        ///  We might consider running this call zoned.
        final data = await Future.sync(() => work(param));
        sendPort.send((id, data));
      } catch (e, stackTrace) {
        sendPort.send((id, RemoteError(e.toString(), stackTrace.toString())));
      }
      // });
    }
  }

  static void Function(SendPort) _startRemoteIsolate<P, R>(
      FutureOr<R> Function(P) work) {
    return (sendPort) {
      final receivePort = ReceivePort();
      sendPort.send(receivePort.sendPort);
      _handleCommandsToIsolate(receivePort, sendPort, work);
    };
  }

  /// Runs the assigned task to the worker on the given [value], returning a [Future] that completes with the given value.
  ///
  /// If the given task throws, then this function throws a [RemoteError] with the given information from the original exception/error.
  Future<R> run(P value) async {
    if (_closed) throw StateError('Closed');
    final completer = Completer<R>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _commands.send((id, value));
    return await completer.future.then((value) {
      if (_activeRequests.isEmpty) _onCleanup?.call();
      return value;
    });
  }

  /// Closes the worker and kills the associated isolate
  void close() {
    if (!_closed) {
      _closed = true;
      _commands.send(WorkerTask.shutdown);
      if (_activeRequests.isEmpty) _responses.close();
    }
  }
}

enum WorkerTask {
  shutdown;
}

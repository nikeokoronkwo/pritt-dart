import 'dart:async';
import 'package:pritt_server_core/pritt_server_core.dart';


import '../../crs.dart';

class CRSWorkerDelegate {}

class PubTaskItem extends TaskBase {
  @override
  String id;

  PublishingTask? _savedTask;
  TaskStatus _status = TaskStatus.queue;

  FutureOr<PublishingTask> get taskInfo async =>
      _savedTask ?? await crs.db.getPublishingTaskById(id);

  @override
  TaskStatus get status => _status;

  @override
  FutureOr<void> updateStatus(TaskStatus newStatus, {String? message}) async {
    _savedTask = await crs.db.updatePublishingTaskStatus(
      id,
      status: newStatus,
      message: message,
    );
    _status = newStatus;
  }

  PubTaskItem(this.id);

  @override
  void updateError(Object error) {
    // TODO: Implement updateError
    // if (error is Exception) {
    //
    // }
  }
}

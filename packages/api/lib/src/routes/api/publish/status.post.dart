import 'package:pritt_common/interface.dart' as common;

import 'package:pritt_server_core/pritt_server_core.dart';

import '../../../crs.dart';
import '../../../utils/authorization.dart';
import '../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  final id = getQueryParams(event)['id'] as String;

  final authHeader = getHeader(event, 'Authorization');
  final user = authHeader == null ? null : await checkAuthorization(authHeader);

  if (user == null) {
    setResponseCode(event, 401);
    return common.UnauthorizedError(error: 'UnauthorizedError').toJson();
  }

  try {
    final pubTask = await crs.db.getPublishingTaskById(id);

    return common.PublishPackageStatusResponse(
      status: switch (pubTask.status) {
        TaskStatus.pending => common.PublishingStatus.pending,
        TaskStatus.success => common.PublishingStatus.success,
        TaskStatus.fail => common.PublishingStatus.error,
        TaskStatus.expired => common.PublishingStatus.error,
        TaskStatus.idle => common.PublishingStatus.idle,
        TaskStatus.queue => common.PublishingStatus.queue,
        TaskStatus.error => common.PublishingStatus.error,
      },
      name: pubTask.name,
      version: pubTask.version,
      scope: pubTask.scope,
      error:
          pubTask.status == TaskStatus.fail ||
              pubTask.status == TaskStatus.error
          ? pubTask.message ?? 'Publishing task failed: unknown error'
          : null,
    ).toJson();
  } catch (e, st) {
    print('$e: $st');
    setResponseCode(event, 500);
    return common.ServerError(error: 'Server').toJson();
  }
});

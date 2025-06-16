import 'package:pritt_common/interface.dart' as common;

import '../../../../pritt_server.dart';
import '../../../main/base/db/schema.dart';
import '../../../server_utils/authorization.dart';
import '../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  final id = getQueryParams(event)['id'] as String;

  var authHeader = getHeader(event, 'Authorization');
  final user = await checkAuthorization(authHeader);

  if (user == null) {
    setResponseCode(event, 401);
    return common.UnauthorizedError(error: 'UnauthorizedError').toJson();
  }

  try {
    final pubTask = await crs.db.getPublishingTaskById(id);

    return common.PublishPackageStatusResponse(status: switch (pubTask.status) {
      TaskStatus.pending => common.PublishingStatus.pending,
      TaskStatus.success => common.PublishingStatus.success,
      TaskStatus.fail => common.PublishingStatus.error,
      TaskStatus.expired => common.PublishingStatus.error,
      TaskStatus.idle => common.PublishingStatus.idle,
      TaskStatus.queue => common.PublishingStatus.queue,
      TaskStatus.error => common.PublishingStatus.error,
    }).toJson();
  } catch (e) {
    setResponseCode(event, 500);
    return common.ServerError(error: 'Server Error').toJson();
  }
});
import 'package:pritt_common/interface.dart' as common;

import '../../../../../pritt_server.dart';
import '../../../../main/base/db/schema.dart';
import '../../../../main/crs/exceptions.dart';
import '../../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {

  // get id
  final id = getParams(event, 'id') as String;

  // get auth session
  try {
    final details = await crs.db.getAuthSessionDetails(sessionId: id);

    final resp = common.AuthDetailsResponse(
        token: id,
        token_expires: details.expiresAt.toIso8601String(),
        device: details.deviceId,
        code: details.code,
        status: switch (details.status) {
          TaskStatus.pending => common.PollStatus.pending,
          TaskStatus.success => common.PollStatus.success,
          TaskStatus.fail => common.PollStatus.fail,
          TaskStatus.expired => common.PollStatus.expired,
          TaskStatus.error => common.PollStatus.error,
          _ => common.PollStatus.pending,
        },
        user_id: details.userId);

    return resp.toJson();
  } on CRSException catch (e) {
    setResponseCode(event, 404);
    return common.NotFoundError(error: 'UnauthorizedError', message: e.message).toJson();
  }
});

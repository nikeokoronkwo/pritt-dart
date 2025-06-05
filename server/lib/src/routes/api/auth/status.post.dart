import 'package:pritt_common/interface.dart' as common;

import 'package:pritt_server/pritt_server.dart';
import 'package:pritt_server/src/main/base/db/schema.dart';
import 'package:pritt_server/src/utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  final id = getQueryParams(event)['id'];

  if (id == null) {
    setResponseCode(event, 404);
    return {
      'error': 'Invalid or Unknown ID',
      'message': 'Could not get session id'
    };
  }

  // TODO: Validate if ID exists, return 404
  final (status: status, id: userId) =
      await crs.db.getAuthSessionStatus(sessionId: id);

  switch (status) {
    case TaskStatus.pending:
      final resp = common.AuthPollResponse(
          status: switch (status) {
        TaskStatus.pending => common.PollStatus.pending,
        TaskStatus.success => common.PollStatus.success,
        TaskStatus.fail => common.PollStatus.fail,
        TaskStatus.expired => common.PollStatus.expired,
        TaskStatus.error => common.PollStatus.error,
      });

      return resp.toJson();
    case TaskStatus.success:
      final (
        session: updatedSession,
        token: accessToken,
        tokenExpiration: accessTokenExpiresAt
      ) = await crs.db.updateAuthSessionWithAccessToken(sessionId: id);
      final resp = common.AuthPollResponse(
          status: switch (status) {
            TaskStatus.pending => common.PollStatus.pending,
            TaskStatus.success => common.PollStatus.success,
            TaskStatus.fail => common.PollStatus.fail,
            TaskStatus.expired => common.PollStatus.expired,
            TaskStatus.error => common.PollStatus.error,
          },
          response: {
            'id': userId,
            'access_token': accessToken,
            'access_token_expires_at': accessTokenExpiresAt
          });

      return resp.toJson();
    case TaskStatus.fail:
      // TODO: Handle this case.
      throw UnimplementedError();
    case TaskStatus.expired:
      // TODO: Handle this case.
      throw UnimplementedError();
    case TaskStatus.error:
      // TODO: Handle this case.
      throw UnimplementedError();
  }
});

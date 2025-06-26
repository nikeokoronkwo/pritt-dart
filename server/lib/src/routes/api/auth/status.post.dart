import 'package:pritt_common/interface.dart' as common;

import '../../../../pritt_server.dart';
import '../../../main/base/db/schema.dart';
import '../../../utils/request_handler.dart';

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
      final resp = common.AuthPollResponse(status: common.PollStatus.pending);

      return resp.toJson();
    case TaskStatus.success:
      final (
        session: updatedSession,
        token: accessToken,
        tokenExpiration: accessTokenExpiresAt
      ) = await crs.db.updateAuthSessionWithAccessToken(sessionId: id);
      final resp =
          common.AuthPollResponse(status: common.PollStatus.success, response: {
        'id': userId,
        'access_token': accessToken,
        'access_token_expires_at': accessTokenExpiresAt.toIso8601String()
      });

      return resp.toJson();
    case TaskStatus.fail:
      return common.AuthPollResponse(status: common.PollStatus.fail).toJson();
    case TaskStatus.expired:
      return common.AuthPollResponse(status: common.PollStatus.expired)
          .toJson();
    case TaskStatus.error:
      return common.AuthPollResponse(status: common.PollStatus.error).toJson();
    default:
      return common.AuthPollResponse(status: common.PollStatus.pending)
          .toJson();
  }
});

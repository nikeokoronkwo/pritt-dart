import 'dart:convert';

import 'package:pritt_server/pritt_server.dart';
import 'package:pritt_server/src/main/base/db/schema.dart';
import 'package:pritt_server/src/utils/request_handler.dart';
import 'package:pritt_common/interface.dart' as common;

final handler = defineRequestHandler((event) async {
  try {
    // read the body
    // get the following details: user_id
    final body = await getBody(event,
        (body) => common.AuthValidateRequest.fromJson(json.decode(body)));

    // update the status
    final session = await crs.db
        .completeAuthSession(sessionId: body.session_id, userId: body.user_id);

    // check status
    switch (session.status) {
      case TaskStatus.success:
        final resp = common.AuthValidateResponse(validated: true);
        return resp.toJson();
      case TaskStatus.fail:
        final resp = common.AuthValidateResponse(validated: false);
        return resp.toJson();
      case TaskStatus.expired:
        setResponseCode(event, 405);
        return {
          'error': 'Authorization has expired. Please try again',
          'expired_time': session.expiresAt.toIso8601String()
        };
      default:
        setResponseCode(event, 402);
        return {
          'error': 'The authorization did not complete, or errored out',
          'status': session.status.name
        };
    }
  } on TypeError catch (e) {
    setResponseCode(event, 400);
    return {'name': 'Invalid Request', 'error': 'Invalid Body for Request'};
  }
});

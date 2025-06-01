import 'package:pritt_common/interface.dart' as common;

import 'package:pritt_server/pritt_server.dart';
import 'package:pritt_server/src/utils/request_handler.dart';
import 'package:pritt_server/src/utils/resolve.dart';

final handler = defineRequestHandler((event) async {
  // TODO: In the future, we want to assert a device id is passed
  final deviceId = getQueryParams(event)['id'] ?? 'anonymous';

  // make sure this is the pritt CLI
  final userAgent = getUserAgentFromHeader(getHeaders(event));

  if (!userAgent.toString().toLowerCase().contains('pritt cli')) {
    setResponseCode(event, 401);
    return 'Unauthorized: You should not be accessing this';
  }

  try {
    // create new auth
    final authSession = await crs.db.createNewAuthSession(deviceId: deviceId);

    // make a response
    final response = common.AuthResponse(
        token: authSession.sessionId,
        token_expires: authSession.expiresAt.toIso8601String(),
        device: authSession.deviceId,
        code: authSession.code);

    return response.toJson();
  } catch (e) {
    // handle exception
    setResponseCode(event, 500);
    return 'Unknown Error';
  }
});

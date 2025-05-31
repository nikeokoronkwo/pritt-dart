
import 'package:pritt_common/interface.dart' as common;

import 'package:pritt_server/pritt_server.dart';
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
  final status = await crs.db.getAuthSessionStatus(sessionId: id);

  final resp = common.AuthPollResponse(status: status.name);

  return resp.toJson();
});
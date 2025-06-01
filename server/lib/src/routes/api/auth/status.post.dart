
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
  final (status: status, id: userId) = await crs.db.getAuthSessionDetails(sessionId: id);

  switch (status) {

    case TaskStatus.pending:
      final resp = common.AuthPollResponse(status: switch (status) {
        TaskStatus.pending => common.PollStatus.pending,
        TaskStatus.success => common.PollStatus.success,
        TaskStatus.fail => common.PollStatus.fail,
        TaskStatus.expired => common.PollStatus.expired,
        TaskStatus.error => common.PollStatus.error,
      }, response: null);

      return resp.toJson();
    case TaskStatus.success:
      final resp = common.AuthPollResponse(status: switch (status) {
        TaskStatus.pending => common.PollStatus.pending,
        TaskStatus.success => common.PollStatus.success,
        TaskStatus.fail => common.PollStatus.fail,
        TaskStatus.expired => common.PollStatus.expired,
        TaskStatus.error => common.PollStatus.error,
      }, response: {
        'id':
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
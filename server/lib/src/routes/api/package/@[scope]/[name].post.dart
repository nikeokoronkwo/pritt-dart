
import 'package:pritt_common/interface.dart' as common;

import '../../../../../pritt_server.dart';
import '../../../../server_utils/authorization.dart';
import '../../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // parse info
  final pkgName = getParams(event, 'name') as String;
  final pkgScope = getParams(event, 'scope') as String;

  try {
    // check if user is authenticated
    var authHeader = getHeader(event, 'Authorization');
    final user = await checkAuthorization(authHeader);

    if (user == null) {
      setResponseCode(event, 401);
      return common.UnauthorizedError(error: 'UnauthorizedError').toJson();
    }

    // check if user is in scope
    final members = crs.db.getMembersForOrganizationStream(pkgScope);
    if (!(await members.contains(user))) {
      setResponseCode(event, 401);
      return common.UnauthorizedError(error: 'UnauthorizedError', reason: common.UnauthorizedReason.org).toJson();
    }

    // from info...
    // get pkg name, pkg version

    // get pkg pritt config, if any
    // TODO: Pritt Configuration

    // check if package exists
    // if it does, throw error

    // add package queue task
    // TODO: Contributors

    // get queue details

    // send details down
  } catch (e) {

  }

});

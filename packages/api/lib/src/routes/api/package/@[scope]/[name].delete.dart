import 'dart:convert';

import 'package:pritt_common/interface.dart' as common;
import 'package:pritt_server_core/pritt_server_core.dart';

import '../../../../crs.dart';
import '../../../../utils/authorization.dart';
import '../../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // parse info
  final pkgName = getParams(event, 'name') as String;
  final pkgScope = getParams(event, 'scope') as String;

  try {
    // check if user is authenticated
    final authHeader = getHeader(event, 'Authorization');
    final user = authHeader == null
        ? null
        : await checkAuthorization(authHeader);

    if (user == null) {
      setResponseCode(event, 401);
      return common.UnauthorizedError(error: 'UnauthorizedError').toJson();
    }

    final body = await getBody(
      event,
      (s) => common.RemovePackageRequest.fromJson(json.decode(s)),
    );

    final pkgDetails = await crs.db.getPackage(pkgName, scope: pkgScope);
    final pkgs = await crs.db.getAllVersionsOfPackage(pkgName, scope: pkgScope);
    final pkgContributors = crs.db.getContributorsForPackageStream(
      pkgName,
      scope: pkgScope,
    );

    // Only author can deprecate
    if (pkgDetails.author != user &&
        !(await pkgContributors
            .where((contrib) => contrib.$2.contains(Privileges.write))
            .contains(user))) {
      setResponseCode(event, 401);
      return common.UnauthorizedError(error: 'UnauthorizedError').toJson();
    }

    if (body.yank ?? false) {
      // yank
    } else {
      // deprecate
      assert(
        pkgs.first.isDeprecated,
        "The latest version of the package must be deprecated",
      );
    }
  } on AssertionError catch (e) {
    setResponseCode(event, 400);
    return common.Error(error: e.message.toString()).toJson();
  } catch (e) {
    setResponseCode(event, 500);
    return common.ServerError(error: e.toString()).toJson();
  }
});

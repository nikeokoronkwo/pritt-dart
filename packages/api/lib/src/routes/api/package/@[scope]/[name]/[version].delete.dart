import 'dart:convert';

import 'package:pritt_common/functions.dart';
import 'package:pritt_common/interface.dart' as common;
import 'package:pritt_common/version.dart';
import 'package:pritt_server_core/pritt_server_core.dart';

import '../../../../../crs.dart';
import '../../../../../utils/authorization.dart';
import '../../../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // parse info
  final pkgName = getParams(event, 'name') as String;
  final pkgVer = Version.parse(getParams(event, 'version') as String);
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

    final pkgDetails = await crs.db.getPackage(pkgName, scope: pkgScope);
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

    final body = await getBody(
      event,
      (s) => common.RemovePackageByVersionRequest.fromJson(json.decode(s)),
    );

    final pkg = await crs.db.getPackageWithVersion(
      pkgName,
      pkgVer,
      scope: pkgScope,
    );

    if (body.yank ?? false) {
      if (pkg.isYanked) {
        return common.RemovePackageByVersionResponse(
          success: true,
          package_name: scopedName(pkgName, pkgScope),
          request_type: common.RequestType.yank,
        ).toJson();
      }

      try {
        final output = await crs.ofs.getPackage(pkg.archive.toString());

        assert(
          output.data.isEmpty || output.size == 0,
          "In order to yank package, the package has to be removed",
        );

        await crs.ofs.removePackage(pkg.archive.toString());
      } catch (e) {
        // continue
      }

      final _ = await crs.db.yankVersionOfPackage(
        pkgName,
        pkgVer,
        scope: pkgScope,
      );

      return common.RemovePackageByVersionResponse(
        success: true,
        package_name: scopedName(pkgName, pkgScope),
        request_type: common.RequestType.yank,
      ).toJson();
    } else {
      if (pkg.isDeprecated) {
        return common.RemovePackageByVersionResponse(
          success: true,
          package_name: scopedName(pkgName, pkgScope),
          request_type: common.RequestType.deprecate,
        ).toJson();
      }

      final altPackageName = body.alternative != null
          ? parsePackageName(body.alternative!)
          : null;
      final altPackage = altPackageName == null
          ? null
          : await crs.db.getPackage(
              altPackageName.$1,
              scope: altPackageName.scope,
            );
      final _ = await crs.db.deprecateVersionOfPackage(
        pkgName,
        pkgVer,
        scope: pkgScope,
        alternative: altPackage,
        message: body.reason,
      );

      return common.RemovePackageByVersionResponse(
        success: true,
        package_name: scopedName(pkgName, pkgScope),
        request_type: common.RequestType.deprecate,
      ).toJson();
    }
  } on CRSException catch (e) {
    switch (e.type) {
      case CRSExceptionType.SCOPE_NOT_FOUND:
        setResponseCode(event, 404);
        return common.NotFoundError(
          error:
              'The given scope $pkgScope could not be found. You will need to create the scope first',
        );
      case CRSExceptionType.PACKAGE_NOT_FOUND:
        setResponseCode(event, 404);
        return common.NotFoundError(
          error:
              'The given package ${scopedName(pkgName, pkgScope)} could not be found',
        );
      default:
        setResponseCode(event, 500);
        return common.ServerError(error: 'Server Error').toJson();
    }
  } catch (e) {
    setResponseCode(event, 500);
    return common.ServerError(error: 'Server Error').toJson();
  }
});

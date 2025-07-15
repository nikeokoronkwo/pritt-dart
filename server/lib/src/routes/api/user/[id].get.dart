import 'package:async/async.dart';
import 'package:pritt_common/interface.dart' as common;

import '../../../../pritt_server.dart';
import '../../../main/base/db/schema.dart';
import '../../../main/crs/exceptions.dart';
import '../../../server_utils/authorization.dart';
import '../../../utils/extensions.dart';
import '../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  try {
    final id = getParams(event, 'id') as String;

    var authHeader = getHeader(event, 'Authorization');
    var authUser = authHeader == null ? null : await checkAuthorization(authHeader);

    final user = await crs.db.getUser(id);

    var root = authUser == user;

    // TODO(nikeokoronkwo): What of packages he/she contributes to?, https://github.com/nikeokoronkwo/pritt-dart/issues/63
    final packages = crs.db.getPackagesForUserStream(id);
    final contributedPackages = crs.db.getPackagesContributedToByUserStream(id);

    final approvedPkgsGroup = StreamGroup<(Package, Iterable<Privileges>)>()
    ..add((root ? packages : packages.asyncMap((pkg) async {
      if (pkg.public ?? true) return pkg;

      if (pkg.scoped) {
        // get scope members
        final members = crs.db.getMembersForOrganizationStream(pkg.scope!);

        // check if user is a member of the scope
        // if so, return the package
        // else, return null
        return (await members.contains(authUser) ? pkg : null);
      } else {
        return null;
      }
    }).nonNull()).map((pkg) => (pkg, [Privileges.ultimate])))
    ..add((root ? contributedPackages : contributedPackages.asyncMap((pkg) async {
      if (pkg.$1.public ?? true) return pkg;

      if (pkg.$1.scoped) {
        // get scope members
        final members = crs.db.getMembersForOrganizationStream(pkg.$1.scope!);

        // check if user is a member of the scope
        // if so, return the package
        // else, return null
        return (await members.contains(authUser) ? pkg : null);
      } else {
        return null;
      }
    }).nonNull()));

    return common.GetUserResponse(
      name: user.name,
      email: user.email,
      created_at: user.createdAt.toIso8601String(),
      updated_at: user.updatedAt.toIso8601String(),
      packages: await approvedPkgsGroup.stream
          .map(
            (pkgRecord) => common.PackageMap(
              name: pkgRecord.$1.name,
              type: pkgRecord.$2.contains(Privileges.ultimate) ? common.UserPackageRelationship.author : common.UserPackageRelationship.contributor,
              privileges: pkgRecord.$2.contains(Privileges.ultimate)
                  ? null
                  : pkgRecord.$2.map((p) => switch (p) {
                    Privileges.read => common.Privilege.read,
                    Privileges.write => common.Privilege.write,
                    Privileges.publish => common.Privilege.publish,
                    Privileges.ultimate => common.Privilege.ultimate,
                  }).toList(),
            ),
          )
          .toList(),
    ).toJson();
  } on CRSException catch (e) {
    switch (e.type) {
      case CRSExceptionType.USER_NOT_FOUND:
        setResponseCode(event, 404);
        return common.NotFoundError(error: 'NotFound', message: e.message).toJson();
      default:
        setResponseCode(event, 500);
        return common.ServerError(error: e.message).toJson();
    }
  }
});
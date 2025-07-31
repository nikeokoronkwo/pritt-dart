import 'package:async/async.dart';
import 'package:pritt_common/interface.dart' as common;
import 'package:pritt_server_core/pritt_server_core.dart';

import '../../../crs.dart';
import '../../../utils/authorization.dart';
import '../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  try {
    final authHeader = getHeader(event, 'Authorization');
    final user = authHeader == null
        ? null
        : await checkAuthorization(authHeader);

    if (user == null) {
      setResponseCode(event, 404);
      return common.NotFoundError(
        error: 'NotFound',
        message: 'User could not be found',
      ).toJson();
    }

    final pkgs = crs.db.getPackagesForUserStream(user.id);
    final contributedPackages = crs.db.getPackagesContributedToByUserStream(
      user.id,
    );

    final approvedPkgsGroup = StreamGroup<(Package, Iterable<Privileges>)>()
      ..add(pkgs.map((pkg) => (pkg, [Privileges.ultimate])))
      ..add(contributedPackages);

    return common.GetUserResponse(
      name: user.name,
      email: user.email,
      created_at: user.createdAt.toIso8601String(),
      updated_at: user.updatedAt.toIso8601String(),
      packages: await approvedPkgsGroup.stream
          .map(
            (pkgRecord) => common.PackageMap(
              name: pkgRecord.$1.name,
              type: pkgRecord.$2.contains(Privileges.ultimate)
                  ? common.UserPackageRelationship.author
                  : common.UserPackageRelationship.contributor,
              privileges: pkgRecord.$2.contains(Privileges.ultimate)
                  ? null
                  : pkgRecord.$2
                        .map(
                          (p) => switch (p) {
                            Privileges.read => common.Privilege.read,
                            Privileges.write => common.Privilege.write,
                            Privileges.publish => common.Privilege.publish,
                            Privileges.ultimate => common.Privilege.ultimate,
                          },
                        )
                        .toList(),
            ),
          )
          .toList(),
    ).toJson();
  } on CRSException catch (e) {
    switch (e.type) {
      case CRSExceptionType.USER_NOT_FOUND:
        setResponseCode(event, 404);
        return common.NotFoundError(
          error: 'NotFound',
          message: e.message,
        ).toJson();
      default:
        setResponseCode(event, 500);
        return common.ServerError(error: e.message).toJson();
    }
  }
});

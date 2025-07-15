import 'package:pritt_common/interface.dart';

import '../../../../pritt_server.dart';
import '../../../main/crs/exceptions.dart';
import '../../../server_utils/authorization.dart';
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

    

    return GetUserResponse(
      name: user.name,
      email: user.email,
      created_at: user.createdAt.toIso8601String(),
      updated_at: user.updatedAt.toIso8601String(),
      packages: await packages
          .map(
            (pkg) => PackageMap(
              name: pkg.name,
              type: UserPackageRelationship.author,
            ),
          )
          .toList(),
    ).toJson();
  } on CRSException catch (e) {
    switch (e.type) {
      case CRSExceptionType.USER_NOT_FOUND:
        setResponseCode(event, 404);
        return NotFoundError(error: 'NotFound', message: e.message).toJson();
      default:
        setResponseCode(event, 500);
        return ServerError(error: e.message).toJson();
    }
  }
});
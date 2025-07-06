import 'package:pritt_common/interface.dart';

import '../../../../pritt_server.dart';
import '../../../main/crs/exceptions.dart';
import '../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  try {
    final id = getParams(event, 'id') as String;

    final user = await crs.db.getUser(id);

    // TODO(nikeokoronkwo): What of packages he/she contributes to?, https://github.com/nikeokoronkwo/pritt-dart/issues/63
    final packages = crs.db.getPackagesForUserStream(id);

    // bool isAuthorized = false;

    // var authHeader = getHeader(event, 'Authorization');
    // isAuthorized = authHeader == null
    //     ? false
    //     : (await checkAuthorization(authHeader) != null);

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

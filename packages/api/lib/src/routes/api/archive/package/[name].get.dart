import 'package:pritt_common/interface.dart' as common;
import 'package:pritt_common/version.dart';
import 'package:pritt_server_core/pritt_server_core.dart';


import '../../../../crs.dart';
import '../../../../utils/authorization.dart';
import '../../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // check authorization
  final authToken = getHeader(event, 'Authorization');
  final user = authToken == null ? null : await checkAuthorization(authToken);

  if (user == null) {
    setResponseCode(event, 401);
    return common.UnauthorizedError(
      error: 'Unauthorized',
      description: 'You are not authorized to view or use this endpoint',
    ).toJson();
  }

  // get tarball for package
  // get pkg name
  final pkgName = getParams(event, 'name') as String;

  // get query params
  final version = getQueryParams(event)['version'];

  // check version is valid
  if (version != null && Version.tryParse(version) == null) {
    final String errorMsg = version.startsWith('v') || version.startsWith('@')
        ? 'Versions must start with their plain number, no "v<version>" or "@<version>"'
        : 'Versions must follow semver';

    setResponseCode(event, 403);
    return {
      'error': 'Invalid Parameter',
      'message': 'The version $version is invalid: $errorMsg',
    };
  }

  try {
    // find the package exists in the registry
    final package = await (version == null
        ? crs.getLatestPackage(pkgName)
        : crs.getPackageWithVersion(pkgName, version));

    if (!package.isSuccess) {
      setResponseCode(event, 404);
      return common.NotFoundError(
        error: 'Package not found',
        message: 'The package $pkgName could not be found',
      ).toJson();
    }

    final archive = await crs.ofs.getPackage(package.body!.archive.path);

    return archive.data;
  } on CRSException {
    // handle error
  } catch (e) {
    // unknown error
    setResponseCode(event, 500);
    return 'An Unknown Error Occured';
  }
});

import 'package:pritt_server/pritt_server.dart';
import 'package:pritt_server/src/main/crs/exceptions.dart';
import 'package:pritt_server/src/main/utils/version.dart';

import '../../../../server_utils/authorization.dart';
import '../../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // check authorization
  final authToken = getHeader(event, 'Authorization');
  final auth = await checkAuthorization(authToken);

  if (auth != null) {
    setResponseCode(event, 401);
    return {
      'error': 'Unauthorized',
      'message': 'You are not authorized to view or use this endpoint'
    };
  }

  // get tarball for package
  // get pkg name
  final pkgName = getParams(event, 'name') as String;

  // get query params
  final version = getQueryParams(event)['version'];

  // check version is valid
  if (version != null && Version.tryParse(version) == null) {
    String errorMsg = version.startsWith('v') || version.startsWith('@')
        ? 'Versions must start with their plain number, no "v<version>" or "@<version>"'
        : 'Versions must follow semver';

    setResponseCode(event, 403);
    return {
      'error': 'Invalid Parameter',
      'message': 'The version $version is invalid: $errorMsg'
    };
  }

  try {
    // find the package exists in the registry
    final package = await (version == null
        ? crs.getLatestPackage(pkgName)
        : crs.getPackageWithVersion(pkgName, version));

    if (!package.isSuccess) {
      setResponseCode(event, 404);
      return {
        'error': 'Package not found',
        'message': 'The package $pkgName could not be found'
      };
    }

    final archive = await crs.ofs.get(package.body!.archive.path);

    return archive.data;
  } on CRSException catch (e) {
    // handle error
  } catch (e) {
    // unknown error
    setResponseCode(event, 500);
    return 'An Unknown Error Occured';
  }
});

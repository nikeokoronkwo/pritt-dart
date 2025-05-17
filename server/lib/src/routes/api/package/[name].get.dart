import 'package:pritt_server/pritt_server.dart';
import 'package:pritt_server/src/main/crs/exceptions.dart';
import 'package:pritt_server/src/main/shared/version.dart';
import 'package:pritt_server/src/server_utils/authorization.dart';
import 'package:pritt_server/src/server_utils/response_pkgver.dart';
import 'package:pritt_server/src/utils/request_handler.dart';
import 'package:shelf/shelf.dart';

final handler = defineRequestHandler((event) async {
  // get pkg name
  final pkgName = getParams(event, 'name');

  // check authorization
  var authHeader = getHeader(event, 'Authorization');
  final isAuthorized = await checkAuthorization(authHeader) != null;

  try {
    // get the package
    final pkg = await crs.db.getPackage(pkgName);

    // get the package versions
    final pkgVersions = (await crs.db.getAllVersionsOfPackage(pkgName)).toList()
      ..sort((a, b) {
        final verA = Version.parse(a.version);
        final verB = Version.parse(b.version);
        return verA.compareTo(verB);
      });

    // get contributors
    final contributors = await crs.db.getContributorsForPackage(pkgName);

    return Response.ok({
      'name': pkg.name,
      'version': pkg.version,
      'author': {
        'name': pkg.author.name,
        'email': pkg.author.email,
      },
      'contributors': contributors.entries.map((e) => {
            'name': e.key.name,
            'email': e.key.email,
            'privileges':
                isAuthorized ? e.value.map((priv) => priv.toString()) : null
          }),
      'language': pkg.language,
      'created_at': pkg.created.toIso8601String(),
      'description': pkg.description,
      'latest_version': pkg.version,
      'latest': ResponsePkgVer.fromPackageVersion(
          pkgVersions.firstWhere((p) => p.version == pkg.version)).toJson(),
      'versions': pkgVersions.asMap().map((index, pkgVer) {
        return MapEntry(
            pkgVer.version, ResponsePkgVer.fromPackageVersion(pkgVer).toJson());
      }),
    });

    // if package not found, return 404
  } on CRSException catch (e) {
    switch (e.type) {
      case CRSExceptionType.PACKAGE_NOT_FOUND:
        return Response.notFound({
          'error': 'Package not found',
          'message': 'Package with name $pkgName not found'
        });
      case CRSExceptionType.VERSION_NOT_FOUND:
        return Response.notFound({
          'error': 'Version not found',
          'message': 'Some versions of the package $pkgName were not found'
        });
      default:
        return Response.internalServerError(body: 'Internal server error');
    }
  } catch (e) {
    return Response.internalServerError(body: 'Internal server error');
  }
});

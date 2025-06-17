import 'package:pritt_common/interface.dart' as common;
import 'package:pritt_common/version.dart';
import '../../../../../../pritt_server.dart';
import '../../../../../main/base/db/schema.dart';
import '../../../../../main/crs/exceptions.dart';
import '../../../../../server_utils/authorization.dart';
import '../../../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // get pkg name
  final pkgName = getParams(event, 'name') as String;
  final pkgScope = getParams(event, 'scope') as String;
  final pkgVer = Version.parse(getParams(event, 'version') as String);

  // check authorization
  var authHeader = getHeader(event, 'Authorization');
  final isAuthorized = await checkAuthorization(authHeader) != null;

  try {
    // get the package version
    final pkg =
        await crs.db.getPackageWithVersion(pkgName, pkgVer, scope: pkgScope);

    var author = common.Author(
        name: pkg.package.author.name, email: pkg.package.author.email);

    final contributors =
        await crs.db.getContributorsForPackage(pkgName, scope: pkgScope);

    // return
    final resp = common.GetPackageByVersionResponse(
        name: '${pkg.package.scope}/${pkg.package.name}',
        scope: pkg.package.scope,
        version: pkg.version,
        author: author,
        created_at: pkg.created.toIso8601String(),
        info: pkg.info,
        env: pkg.env,
        metadata: pkg.metadata,
        signatures: pkg.signatures
            .map((sig) => common.Signature(
                public_key_id: sig.publicKeyId,
                signature: sig.signature,
                created: sig.created.toIso8601String()))
            .toList(),
        readme: pkg.readme,
        config: pkg.config == null
            ? null
            : common.ConfigFile(
                name: pkg.configName!,
                data: pkg.config!,
              ),
        deprecated: (isAuthorized) ? pkg.isDeprecated : null,
        yanked: (isAuthorized) ? pkg.isYanked : null,
        deprecationMessage: (isAuthorized) ? pkg.deprecationMessage : null,
        hash: isAuthorized ? pkg.hash : null,
        integrity: isAuthorized ? pkg.integrity : null,
        contributors: contributors.entries.map((e) {
          return common.Contributor(
              name: e.key.name,
              email: e.key.email,
              privileges: isAuthorized
                  ? e.value.map((p) {
                      return switch (p) {
                        Privileges.read => common.Privilege.read,
                        Privileges.write => common.Privilege.write,
                        Privileges.publish => common.Privilege.publish,
                        Privileges.ultimate => common.Privilege.ultimate,
                      };
                    }).toList()
                  : null);
        }).toList());

    return resp.toJson();

    // if package not found, return 404
  } on CRSException catch (e) {
    switch (e.type) {
      case CRSExceptionType.PACKAGE_NOT_FOUND:
        setResponseCode(event, 404);
        return common.NotFoundError(
                error: 'Package not found',
                message: 'Package with name @$pkgScope/$pkgName not found')
            .toJson();
      case CRSExceptionType.VERSION_NOT_FOUND:
        setResponseCode(event, 404);
        return common.NotFoundError(
                error: 'Version not found',
                message:
                    'Some versions of the package @$pkgScope/$pkgName were not found')
            .toJson();
      default:
        setResponseCode(event, 500);
        return 'Internal server error';
    }
  } catch (e) {
    setResponseCode(event, 500);
    return 'Internal server error';
  }
});

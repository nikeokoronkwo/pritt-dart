import 'package:pritt_common/interface.dart' as common;
import 'package:pritt_common/version.dart';
import '../../../../../pritt_server.dart';
import '../../../../main/base/db/schema.dart';
import '../../../../main/crs/exceptions.dart';
import '../../../../server_utils/authorization.dart';
import '../../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // get pkg name
  final pkgName = getParams(event, 'name') as String;

  // check query params
  final isAll = getQueryParams(event)['all'];

  // check authorization
  final authHeader = getHeader(event, 'Authorization');
  final user = authHeader != null ? await checkAuthorization(authHeader) : null;
  final isAuthorized = user != null;

  try {
    // get the package
    final pkg = await crs.db.getPackage(pkgName);

    // get contributors
    final contributors = await crs.db.getContributorsForPackage(pkgName);

    if (!(pkg.public ?? true) &&
        (pkg.author != user || !isAuthorized) &&
        !contributors.keys.contains(user)) {
      throw const CRSException(
        CRSExceptionType.UNAUTHORIZED,
        'Package not found',
      );
    }

    // get the package versions
    final pkgVersions = (await crs.db.getAllVersionsOfPackage(pkgName)).toList()
      ..sort((a, b) {
        final verA = Version.parse(a.version);
        final verB = Version.parse(b.version);
        return verA.compareTo(verB);
      });

    final author = common.Author(
      name: pkg.author.name,
      email: pkg.author.email,
      avatar: pkg.author.avatarUrl,
    );

    // return
    final resp = common.GetPackageResponse(
      name: pkg.name,
      latest_version: pkg.version,
      latest: (() {
        final latestPkg = pkgVersions.firstWhere(
          (pv) => pv.version == pkg.version,
        );
        return common.VerbosePackage(
          name: pkg.name,
          version: latestPkg.version,
          author: author,
          created_at: latestPkg.created.toIso8601String(),
          info: latestPkg.info,
          env: latestPkg.env,
          readme: latestPkg.readme,
          language: pkg.language,
          metadata: latestPkg.metadata,
          signatures: latestPkg.signatures
              .map(
                (sig) => common.Signature(
                  public_key_id: sig.publicKeyId,
                  signature: sig.signature,
                  created: sig.created.toIso8601String(),
                ),
              )
              .toList(),
          deprecated: (isAll == 'true' && isAuthorized)
              ? latestPkg.isDeprecated
              : null,
          yanked: (isAll == 'true' && isAuthorized) ? latestPkg.isYanked : null,
        );
      })(),
      versions: pkgVersions.asMap().map((index, pkgVer) {
        return MapEntry(
          pkgVer.version,
          common.VerbosePackage(
            name: pkg.name,
            version: pkgVer.version,
            author: author,
            created_at: pkgVer.created.toIso8601String(),
            info: pkgVer.info,
            env: pkgVer.env,
            metadata: pkgVer.metadata,
            signatures: pkgVer.signatures
                .map(
                  (sig) => common.Signature(
                    public_key_id: sig.publicKeyId,
                    signature: sig.signature,
                    created: sig.created.toIso8601String(),
                  ),
                )
                .toList(),
            deprecated: (isAll == 'true' && isAuthorized)
                ? pkgVer.isDeprecated
                : null,
            yanked: (isAll == 'true' && isAuthorized) ? pkgVer.isYanked : null,
          ),
        );
      }),
      language: pkg.language,
      created_at: pkg.created.toIso8601String(),
      updated_at: pkg.updated.toIso8601String(),
      description: pkg.description,
      author: author,
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
              : null,
        );
      }).toList(),
      license: pkg.license ?? 'Unknown',
      vcs: switch (pkg.vcs) {
        VCS.git => common.VCS.git,
        VCS.svn => common.VCS.svn,
        VCS.fossil => common.VCS.fossil,
        VCS.mercurial => common.VCS.mercurial,
        VCS.other => common.VCS.other,
      },
      vcs_url: pkg.vcsUrl.toString(),
    );

    return resp.toJson();

    // if package not found, return 404
  } on CRSException catch (e, stack) {
    switch (e.type) {
      case CRSExceptionType.UNAUTHORIZED:
        // TODO: 401 or 404?
        setResponseCode(event, 401);
        return common.UnauthorizedError(
          error: 'Unauthorized',
          reason: common.UnauthorizedReason.protected,
          description: 'You are not authorized to access this package',
        ).toJson();
      case CRSExceptionType.PACKAGE_NOT_FOUND:
        print('${e.message} -- ${e.cause} : ${e.stackTrace} : \n$stack');
        setResponseCode(event, 404);
        return common.NotFoundError(
          error: 'Package not found',
          message: 'Package with name $pkgName not found',
        ).toJson();
      case CRSExceptionType.VERSION_NOT_FOUND:
        setResponseCode(event, 404);
        return common.NotFoundError(
          error: 'Version not found',
          message: 'Some versions of the package $pkgName were not found',
        ).toJson();
      default:
        setResponseCode(event, 500);
        return common.ServerError(error: e.message).toJson();
    }
  } catch (e, stack) {
    setResponseCode(event, 500);
    print('$e : $stack');
    return common.ServerError(error: 'Internal Server Error').toJson();
  }
});

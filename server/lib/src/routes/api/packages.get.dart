import 'package:pritt_common/interface.dart' as common;
import '../../../pritt_server.dart';
import '../../server_utils/access.dart';
import '../../server_utils/authorization.dart';
import '../../utils/extensions.dart';
import '../../utils/request_handler.dart';

const pkgCap = 100;

final handler = defineRequestHandler((event) async {
  /// get params
  final queryParams = getQueryParams(event);
  final authToken = getHeader(event, 'Authorization');
  final user = authToken != null ? await checkAuthorization(authToken) : null;

  // Get the estimate
  final pkgCount = await crs.db.getPackagesCountEstimate();

  if (pkgCount >= pkgCap) {
    // get the packages as a stream
    final pkgs = crs.db.getPackagesStream();

    final approvedPkgs = pkgs.asyncMap((pkg) async {
      final author = pkg.author;
      return await userIsAuthorizedToPackage(pkg, user, author: author)
          ? pkg
          : null;
    }).nonNull();

    // while the stream loads..

    // get the index from the query params
    // if not present, default to 0
    var index = 0;
    if (queryParams['index'] != null) {
      index = int.parse(queryParams['index']!);
    }

    final resp = common.GetPackagesResponse(
      packages: (await approvedPkgs.skip(index * 100).take(pkgCap).toList())
          // TODO: More Package features:
          // - keywords, - license
          .map(
            (pkg) => common.Package(
              name: pkg.name,
              scope: pkg.scope,
              description: pkg.description,
              version: pkg.version,
              author: common.Author(
                name: pkg.author.name,
                email: pkg.author.email,
              ),
              created_at: pkg.created.toIso8601String(),
              updated_at: pkg.updated.toIso8601String(),
              language: pkg.language,
            ),
          )
          .toList(),
      next_url: (index * 100 - pkgCount > 20)
          ? getUrl(event).replace(query: 'index=${index + 1}').toString()
          : null,
    );

    return resp.toJson();
  } else {
    // get the packages as a list
    final pkgs = await crs.db.getPackages();

    final approvedPkgs = (await pkgs.map((pkg) async {
      final author = pkg.author;
      return await userIsAuthorizedToPackage(pkg, user, author: author)
          ? pkg
          : null; // not the author, skip
    }).wait).nonNulls;

    final resp = common.GetPackagesResponse(
      packages: approvedPkgs.map((pkg) {
        return common.Package(
          name: pkg.name,
          description: pkg.description,
          version: pkg.version,
          author: common.Author(name: pkg.author.name, email: pkg.author.email),
          created_at: pkg.created.toIso8601String(),
          updated_at: pkg.updated.toIso8601String(),
          language: pkg.language,
        );
      }).toList(),
    );
    return resp.toJson();
  }
});

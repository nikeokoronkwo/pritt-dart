import 'package:pritt_common/interface.dart' as common;
import '../../../pritt_server.dart';
import '../../utils/request_handler.dart';

const pkgCap = 100;

final handler = defineRequestHandler((event) async {
  /// get params
  final queryParams = getQueryParams(event);

  // Get the estimate
  final pkgCount = await crs.db.getPackagesCountEstimate();

  if (pkgCount >= pkgCap) {
    // get the packages as a stream
    final pkgs = crs.db.getPackagesStream();

    // while the stream loads..

    // get the index from the query params
    // if not present, default to 0
    var index = 0;
    if (queryParams['index'] != null) {
      index = int.parse(queryParams['index']!);
    }

    final resp = common.GetPackagesResponse(
      packages: (await pkgs.skip(index * 100).take(pkgCap).toList())
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

    final resp = common.GetPackagesResponse(
      packages: pkgs.map((pkg) {
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

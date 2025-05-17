import 'package:pritt_server/pritt_server.dart';
import 'package:pritt_server/src/server_utils/response_pkg.dart';
import 'package:pritt_server/src/utils/request_handler.dart';
import 'package:shelf/shelf.dart';

final pkgCap = 100;

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

    return Response.ok({
      'next_url': (index * 100 - pkgCount > 20)
          ? getUrl(event).replace(query: 'index=${index + 1}')
          : null,
      'packages': (await pkgs.skip(index * 100).take(pkgCap).toList())
          .map(ResponsePkg.fromPackage)
          .map((e) => e.toJson())
    });
  } else {
    // get the packages as a list
    final pkgs = await crs.db.getPackages();
    return Response.ok({'packages': pkgs});
  }
});

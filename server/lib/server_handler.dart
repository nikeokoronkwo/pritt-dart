// ignore_for_file: library_prefixes

import 'package:pritt_server/src/routes/api/package/%5Bname%5D/index.get.dart'
    as packageNameGet;
import 'package:pritt_server/src/routes/api/packages.get.dart' as packagesGet;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Handler serverHandler() {
  final app = Router()
    ..get('/', (req) => Response.ok('Hello'))
    ..get('/api/packages', packagesGet.handler)
    ..get('/api/package/:name', packageNameGet.handler);

  return app.call;
}

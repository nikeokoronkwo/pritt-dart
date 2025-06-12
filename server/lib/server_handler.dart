// ignore_for_file: library_prefixes

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'src/routes/api/auth/new.get.dart' as authNewGet;
import 'src/routes/api/auth/status.post.dart' as authStatusPost;
import 'src/routes/api/auth/validate.post.dart' as authValidatePost;
import 'src/routes/api/package/%5Bname%5D/%5Bversion%5D.get.dart'
    as packageNameVersionGet;
// TODO: Autogen this file
import 'src/routes/api/package/%5Bname%5D/index.get.dart' as packageNameGet;
import 'src/routes/api/package/@%5Bscope%5D/%5Bname%5D.get.dart'
    as packageScopeNameGet;
import 'src/routes/api/package/@%5Bscope%5D/%5Bname%5D/%5Bversion%5D.get.dart'
    as packageScopeNameVersionGet;
import 'src/routes/api/packages.get.dart' as packagesGet;

Handler serverHandler() {
  final app = Router()
    ..get('/', (req) => Response.ok('Active'))
    ..get('/api/packages', packagesGet.handler)
    ..get('/api/package/:name', packageNameGet.handler)
    ..get('/api/package/:name/:version', packageNameVersionGet.handler)
    ..get('/api/package/@:scope/:name', packageScopeNameGet.handler)
    ..get('/api/package/@:scope/:name/:version',
        packageScopeNameVersionGet.handler)
    ..get('/api/auth/new', authNewGet.handler)
    ..post('/api/auth/status', authStatusPost.handler)
    ..post('/api/auth/validate', authValidatePost.handler);

  return app.call;
}

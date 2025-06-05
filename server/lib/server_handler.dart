// ignore_for_file: library_prefixes

// TODO: Autogen this file
import 'package:pritt_server/src/routes/api/package/[name]/index.get.dart'
    as packageNameGet;
import 'package:pritt_server/src/routes/api/package/[name]/[version].get.dart'
    as packageNameVersionGet;
import 'package:pritt_server/src/routes/api/package/@[scope]/[name].get.dart'
    as packageScopeNameGet;
import 'package:pritt_server/src/routes/api/package/@[scope]/[name]/[version].get.dart'
    as packageScopeNameVersionGet;
import 'package:pritt_server/src/routes/api/packages.get.dart' as packagesGet;
import 'package:pritt_server/src/routes/api/auth/new.get.dart' as authNewGet;
import 'package:pritt_server/src/routes/api/auth/status.post.dart'
    as authStatusPost;
import 'package:pritt_server/src/routes/api/auth/validate.post.dart'
    as authValidatePost;

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

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

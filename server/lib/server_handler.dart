// ignore_for_file: library_prefixes

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

// TODO(nikeokoronkwo): Autogen this file
import 'src/routes/api/auth/new.get.dart' as authNewGet;
import 'src/routes/api/auth/status.post.dart' as authStatusPost;
import 'src/routes/api/auth/validate.post.dart' as authValidatePost;
import 'src/routes/api/package/@[scope]/[name].get.dart'
    as packageScopeNameGet;
import 'src/routes/api/package/@[scope]/[name].post.dart'
    as packageScopeNamePost;
import 'src/routes/api/package/@[scope]/[name]/[version].get.dart'
    as packageScopeNameVersionGet;
import 'src/routes/api/package/@[scope]/[name]/[version].post.dart'
    as packageScopeNameVersionPost;
import 'src/routes/api/package/[name]/[version].get.dart'
    as packageNameVersionGet;
import 'src/routes/api/package/[name]/[version].post.dart'
    as packageNameVersionPost;
import 'src/routes/api/package/[name]/index.get.dart' as packageNameGet;
import 'src/routes/api/package/[name]/index.post.dart' as packageNamePost;
import 'src/routes/api/package/status.get.dart' as packageStatusGet;
import 'src/routes/api/package/upload.put.dart' as packageUploadPut;
import 'src/routes/api/packages.get.dart' as packagesGet;

Handler serverHandler() {
  final app = Router()
    ..get('/', (req) => Response.ok('Active'))
    ..get('/api/packages', packagesGet.handler)
    ..get('/api/package/:name', packageNameGet.handler)
    ..post('/api/package/:name', packageNamePost.handler)
    ..get('/api/package/:name/:version', packageNameVersionGet.handler)
    ..post('/api/package/:name/:version', packageNameVersionPost.handler)
    ..get('/api/package/@:scope/:name', packageScopeNameGet.handler)
    ..post('/api/package/@:scope/:name', packageScopeNamePost.handler)
    ..get('/api/package/@:scope/:name/:version',
        packageScopeNameVersionGet.handler)
    ..post('/api/package/@:scope/:name/:version',
        packageScopeNameVersionPost.handler)
    ..get('/api/package/status', packageStatusGet.handler)
    ..put('/api/package/upload', packageUploadPut.handler)
    ..get('/api/auth/new', authNewGet.handler)
    ..post('/api/auth/status', authStatusPost.handler)
    ..post('/api/auth/validate', authValidatePost.handler);

  return app.call;
}

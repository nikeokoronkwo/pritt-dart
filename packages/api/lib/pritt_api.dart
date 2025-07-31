// ignore_for_file: library_prefixes

import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

// TODO(nikeokoronkwo): Autogen this file
import 'src/routes/api/archive/package/[name].get.dart'
    as archivePackageNameGet;
import 'src/routes/api/auth/details/[id].get.dart' as authDetailsIdGet;
import 'src/routes/api/auth/new.get.dart' as authNewGet;
import 'src/routes/api/auth/status.post.dart' as authStatusPost;
import 'src/routes/api/auth/validate.post.dart' as authValidatePost;
import 'src/routes/api/package/@[scope]/[name].get.dart' as packageScopeNameGet;
import 'src/routes/api/package/@[scope]/[name].post.dart'
    as packageScopeNamePost;
import 'src/routes/api/package/@[scope]/[name]/[version].delete.dart'
    as packageScopeNameVersionDelete;
import 'src/routes/api/package/@[scope]/[name]/[version].get.dart'
    as packageScopeNameVersionGet;
import 'src/routes/api/package/@[scope]/[name]/[version].post.dart'
    as packageScopeNameVersionPost;
import 'src/routes/api/package/[name]/[version].delete.dart'
    as packageNameVersionDelete;
import 'src/routes/api/package/[name]/[version].get.dart'
    as packageNameVersionGet;
import 'src/routes/api/package/[name]/[version].post.dart'
    as packageNameVersionPost;
import 'src/routes/api/package/[name]/index.get.dart' as packageNameGet;
import 'src/routes/api/package/[name]/index.post.dart' as packageNamePost;
import 'src/routes/api/package/upload.put.dart' as packageUploadPut;
import 'src/routes/api/packages.get.dart' as packagesGet;
import 'src/routes/api/publish/status.post.dart' as publishStatusPost;
import 'src/routes/api/user/[id].get.dart' as userIdGet;
import 'src/routes/api/user/index.get.dart' as userGet;

export 'src/crs.dart';
export 'src/main/publishing/tasks.dart';

Handler serverHandler() {
  final app = Router()
    ..get('/', (req) => Response.ok('Active'))
    ..get('/api/user', userGet.handler)
    ..get('/api/user/<id>', userIdGet.handler)
    ..get('/api/archive/package/<name>', archivePackageNameGet.handler)
    ..get('/api/packages', packagesGet.handler)
    ..get('/api/package/<name>', packageNameGet.handler)
    ..post('/api/package/<name>', packageNamePost.handler)
    ..get('/api/package/<name>/<version>', packageNameVersionGet.handler)
    ..post('/api/package/<name>/<version>', packageNameVersionPost.handler)
    ..delete('/api/package/<name>/<version>', packageNameVersionDelete.handler)
    ..get('/api/package/@<scope>/<name>', packageScopeNameGet.handler)
    ..post('/api/package/@<scope>/<name>', packageScopeNamePost.handler)
    ..get(
      '/api/package/@<scope>/<name>/<version>',
      packageScopeNameVersionGet.handler,
    )
    ..post(
      '/api/package/@<scope>/<name>/<version>',
      packageScopeNameVersionPost.handler,
    )
    ..delete(
      '/api/package/@<scope>/<name>/<version>',
      packageScopeNameVersionDelete.handler,
    )
    ..put('/api/package/upload', packageUploadPut.handler)
    ..post('/api/publish/status', publishStatusPost.handler)
    ..get('/api/auth/new', authNewGet.handler)
    ..get('/api/auth/details/<id>', authDetailsIdGet.handler)
    ..post('/api/auth/status', authStatusPost.handler)
    ..post('/api/auth/validate', authValidatePost.handler);

  return app.call;
}

// TODO: Work on OPTIONS until web requests work!
Handler optionsWithCors({required List<String> allowedMethods}) {
  return (Request request) async {
    final corsHeaders = {
      HttpHeaders.accessControlAllowMethodsHeader: allowedMethods.join(', '),
      HttpHeaders.accessControlAllowHeadersHeader: '*',
      HttpHeaders.accessControlAllowOriginHeader:
          request.headers['origin'] ?? '*',
      HttpHeaders.allowHeader: allowedMethods.join(', '),
      HttpHeaders.dateHeader: DateTime.now().toIso8601String(),
    };

    print(corsHeaders);

    return Response(204, body: null, headers: corsHeaders);
  };
}

/// TODO: A better way to do this would be to patch `Router` with a `route` handler
///  that adds options to the Router by default
/// TODO: Complete this work!
Handler preFlightHandler() {
  final router = Router()
    ..options('/', optionsWithCors(allowedMethods: ['GET']))
    ..options(
      '/api/auth/details/<id>',
      optionsWithCors(allowedMethods: ['GET']),
    )
    ..options('/api/auth/validate', optionsWithCors(allowedMethods: ['POST']));
  return router.call;
}

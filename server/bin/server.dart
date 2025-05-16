import 'dart:io';

import 'package:pritt_server/pritt_server.dart';
import 'package:pritt_server/src/main/crs/crs.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> args) async {
  // PRE SETUP
  // TODO: Can crs be a global variable, to reduce parameter passing down?
  final crs = await CoreRegistryService.connect(
      ofsUrl: String.fromEnvironment('S3_URL',
          defaultValue:
              'http://localhost:${String.fromEnvironment('S3_LOCAL_PORT', defaultValue: '8080')}'));

  // SERVER SETUP
  var app = createRouter(crs);

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}

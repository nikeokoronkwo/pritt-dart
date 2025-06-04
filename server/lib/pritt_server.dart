import 'dart:io';

import 'package:pritt_server/adapter_handler.dart';
import 'package:pritt_server/server_handler.dart';
import 'package:pritt_server/src/main/adapter/adapter_registry.dart';
import 'package:pritt_server/src/main/base/db.dart';
import 'package:pritt_server/src/main/base/storage.dart';
import 'package:shelf/shelf.dart';

import 'src/main/crs/crs.dart';

late CoreRegistryService crs;

late AdapterRegistry registry;

Future<void> startPrittServices({String? ofsUrl, String? dbUrl}) async {
  // Load environment variables for the S3 URL and database connection
  ofsUrl ??= String.fromEnvironment('S3_URL',
      defaultValue:
          'http://localhost:${String.fromEnvironment('S3_LOCAL_PORT', defaultValue: '6007')}');

  final databaseUrl = dbUrl ?? (Platform.environment['DATABASE_URL'] != null ? String.fromEnvironment('DATABASE_URL') : null);
  final dbUri = databaseUrl == null ? null : Uri.parse(databaseUrl);

  // read keys for authentication
  final db = await PrittDatabase.connect(
      host: dbUri?.host ?? String.fromEnvironment('DATABASE_HOST'),
      port: dbUri?.port ??
          int.fromEnvironment('DATABASE_PORT', defaultValue: 5432),
      database:
          dbUri?.pathSegments.first ?? String.fromEnvironment('DATABASE_NAME'),
      username: dbUri?.userInfo.split(':').first ??
          String.fromEnvironment('DATABASE_USERNAME'),
      password: dbUri?.userInfo.split(':').last ??
          String.fromEnvironment('DATABASE_PASSWORD'),
      devMode: (dbUri?.host ?? String.fromEnvironment('DATABASE_HOST')) ==
          'localhost');
  final storage = await PrittStorage.connect(ofsUrl);

  registry = await AdapterRegistry.connect(
    db: db,
    runnerUri: Uri.parse(String.fromEnvironment('PRITT_RUNNER_URL'))
  );

  crs = await CoreRegistryService.connect(db: db, storage: storage);
}

Handler createRouter() {
  // create router for openapi routes

  // the main handler
  /// TODO: We can improve the performance a bit more:
  /// We have two request handlers here, but we only need one.
  /// Rather than cascading between, we can run the two requests in parallel and set priorities
  /// When both finish (the adapter resolver) and the server handler, then the one that is successful gets passed down
  ///
  /// The performance need not be extremely much, so we can (and probably should) use Dart Isolates.
  /// However, I need to find out how to pass [Request] and [Response] objects to and fro
  /// An idea is to implement a [WorkerHandler] object with three functions:
  /// - one to convert the request object into the necessary parameters to the main function
  /// - the main function that is run in the isolate
  /// - one to convert the isolate return to the response object
  ///
  ///
  /// This will be very helpful in DS, where the `vm_isolates` preset may need some message passing,
  /// However, this means that the `Event` object will no longer be standard/based on Shelf [Request]
  final cascade = Cascade().add(adapterHandler(crs)).add(serverHandler());

  return cascade.handler;
}

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

  final dbUri = dbUrl == null ? null : Uri.parse(dbUrl);

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
  );

  crs = await CoreRegistryService.connect(db: db, storage: storage);
}

Handler createRouter() {
  // create router for openapi routes

  // the main handler
  final cascade = Cascade().add(adapterHandler(crs)).add(serverHandler());

  return cascade.handler;
}

import 'dart:io';

import 'package:shelf/shelf.dart';

import 'adapter_handler.dart';
import 'server_handler.dart';
import 'src/main/adapter/adapter_registry.dart';
import 'src/main/base/db.dart';
import 'src/main/base/storage.dart';
import 'src/main/crs/crs.dart';
import 'src/main/publishing/tasks.dart';

late final CoreRegistryService crs;

late final AdapterRegistry registry;

Future<void> startPrittServices({
  String? ofsUrl,
  String? dbUrl,
  bool customAdapters = true,
}) async {
  // Load environment variables for the S3 URL and database connection
  ofsUrl ??=
      Platform.environment['S3_URL'] ??
      'http://localhost:${Platform.environment['S3_LOCAL_PORT'] ?? '6007'}';

  final databaseUrl = dbUrl ?? Platform.environment['DATABASE_URL'];
  final dbUri = databaseUrl == null ? null : Uri.parse(databaseUrl);

  // read keys for authentication
  final db = await PrittDatabase.connect(
    host: (dbUri?.host ?? Platform.environment['DATABASE_HOST'])!,
    port:
        dbUri?.port ??
        int.parse(Platform.environment['DATABASE_PORT'] ?? '5432'),
    database:
        (dbUri?.pathSegments.first ?? Platform.environment['DATABASE_NAME'])!,
    username:
        (dbUri?.userInfo.split(':').first ??
        Platform.environment['DATABASE_USERNAME'])!,
    password:
        (dbUri?.userInfo.split(':').last ??
        Platform.environment['DATABASE_PASSWORD'] ??
        String.fromEnvironment('DATABASE_PASSWORD')),
    devMode:
        (dbUri?.host ?? Platform.environment['DATABASE_HOST']) == 'localhost',
  );

  final PrittStorage storage;
  if (Platform.environment.containsKey('S3_CREDENTIALS_FILE')) {
    final keys = await loadSecretsFromFile(
      Platform.environment['S3_CREDENTIALS_FILE']!,
    );
    if (keys != null) {
      storage = await PrittStorage.connect(
        ofsUrl,
        s3secretKey: keys.secretKey,
        s3accessKey: keys.accessKey,
      );
    } else {
      storage = await PrittStorage.connect(ofsUrl);
    }
  } else {
    storage = await PrittStorage.connect(ofsUrl);
  }

  // TODO: Late Initialization Check
  try {
    final _ = crs;
  } catch (e) {
    crs = await CoreRegistryService.connect(db: db, storage: storage);
  }

  if (customAdapters)
    registry = await AdapterRegistry.connect(
      db: db,
      runnerUri: Uri.parse(Platform.environment['PRITT_RUNNER_URL']!),
    );

  publishingTaskRunner.start();
}

/// Loads credentials from the given [path].
///
/// For cases in development, we will need to bootstrap the
/// Therefore, the credentials we need may be stored in a file, rather than in environment
///
/// This function loads these credentials.
///
/// This should not be done during production: credentials must be ready before server startup
Future<({String accessKey, String secretKey})?> loadSecretsFromFile(
  String path,
) async {
  final file = File(path);

  if (!await file.exists()) {
    return null;
  }

  final lines = await file.readAsLines();
  final credentials = <String, String>{};

  for (var line in lines) {
    if (line.trim().isEmpty || line.trim().startsWith('#')) continue;

    final parts = line.split('=');
    if (parts.length == 2) {
      final key = parts[0].trim();
      final value = parts[1].trim();
      credentials[key] = value;
    }
  }

  return credentials.containsKey('ACCESS_KEY') &&
          credentials.containsKey('SECRET_KEY')
      ? (
          accessKey: credentials['ACCESS_KEY']!,
          secretKey: credentials['SECRET_KEY']!,
        )
      : null;
}

Handler createRouter() {
  // create router for openapi routes

  // the main handler
  /// TODO: We can improve the performance a bit more:
  /// We have two request handlers here, but we only need one.
  /// Rather than cascading between, we can run the two requests (adapter and preflight+server) in parallel and set priorities
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
  final cascade = Cascade()
      .add(adapterHandler(crs))
      .add(preFlightHandler())
      .add(serverHandler());

  return cascade.handler;
}

import 'dart:io';

import 'package:pritt_server_core/pritt_server_core.dart';

late CoreRegistryService crs;

/// Creates and loads the CRS services for use in the server and
/// (temporarily) in the publishing task runner
Future<({PrittDatabase db, PrittStorage storage})> startCRSServices({
  String? ofsUrl,
  String? dbUrl
}) async {
  // Load environment variables for the S3 URL and database connection
  ofsUrl ??=
      Platform.environment['S3_URL'] ??
      'http://localhost:${Platform.environment['S3_LOCAL_PORT'] ?? '6007'}';

  final databaseUrl = dbUrl ?? Platform.environment['DATABASE_URL'];
  final dbUri = databaseUrl == null ? null : Uri.parse(databaseUrl);

  // read keys for authentication
  final db = PrittDatabase.connect(
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
        dbUri?.userInfo.split(':').last ??
        Platform.environment['DATABASE_PASSWORD'] ??
        const String.fromEnvironment('DATABASE_PASSWORD'),
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

  return (storage: storage, db: await db);
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

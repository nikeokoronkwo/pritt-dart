import 'dart:io';

import 'package:postgres/postgres.dart';

void main(List<String> args) {
  // set up your database connection
  final databaseUrl = Platform.environment['DATABASE_URL'];
  final dbUri = databaseUrl == null ? null : Uri.parse(databaseUrl);

  final pgConnection = Connection.open(
    Endpoint(
      host: (dbUri?.host ?? Platform.environment['DATABASE_HOST'])!, 
      port: dbUri?.port ??
          int.parse(Platform.environment['DATABASE_PORT'] ?? '5432'),
      database: (dbUri?.pathSegments.first ?? Platform.environment['DATABASE_NAME'])!,
      username: (dbUri?.userInfo.split(':').first ??
          Platform.environment['DATABASE_USERNAME'])!,
      password: (dbUri?.userInfo.split(':').last ??
          Platform.environment['DATABASE_PASSWORD'] ??
          String.fromEnvironment('DATABASE_PASSWORD')),
    ), settings: ConnectionSettings(
      queryMode: QueryMode.simple
    )
  );

  
}
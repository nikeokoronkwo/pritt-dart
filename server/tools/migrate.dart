

import 'dart:io';

import 'package:migrant/migrant.dart';
import 'package:migrant/testing.dart';
import 'package:migrant_db_postgresql/migrant_db_postgresql.dart';
import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart';

Future<void> main(List<String> args) async {
  final url = args.isNotEmpty ? Uri.parse(args[0]) : null;
  
  final adapterDir = Directory(p.join(p.current, 'sql', 'adapter'));
  final migrationDocs = adapterDir.listSync()
      .whereType<File>()
      .map((file) {
        final fileName = p.basename(file.path);
        final migrationName = fileName.split('_').first;
        return Migration(migrationName, [file.readAsStringSync()]);
      })
      .toList();

  // https://pub.dev/packages/migrant
  final migrations = InMemory(migrationDocs);


  final connection = await Connection.open(
      url == null ? Endpoint(
        host: String.fromEnvironment('DATABASE_HOST'),
        database: String.fromEnvironment('DATABASE_NAME'),
        username: String.fromEnvironment('DATABASE_USERNAME'),
        password: String.fromEnvironment('DATABASE_PASSWORD'),
        port: int.fromEnvironment('DATABASE_PORT', defaultValue: 5432),
      ) : Endpoint(
        host: url.host,
        port: url.port,
        database: url.pathSegments.isNotEmpty ? url.pathSegments.first : 'postgres',
        username: url.userInfo.split(':').first,
        password: url.userInfo.split(':').last,
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable)
  );

  // The gateway is provided by this package.
  final gateway = PostgreSQLGateway(connection);

  // Applying migrations.
  await Database(gateway).upgrade(migrations);

  await connection.close();
}
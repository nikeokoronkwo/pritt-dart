import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart';

final argParser = ArgParser(allowTrailingOptions: true)
  ..addOption(
    'directory',
    abbr: 'd',
    help: 'The migrations directory',
    defaultsTo: 'sql',
  )
  ..addOption(
    'table',
    help: 'The name of the SQL migration table name',
    defaultsTo: '_migrations',
  )
  ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help information');

void main(List<String> args) async {
  // parse arguments
  final argResults = argParser.parse(args);
  if (argResults.wasParsed('help')) {
    print(argParser.usage);
    return;
  }

  // set up your database connection
  final databaseUrl = Platform.environment['DATABASE_URL'];
  final dbUri = databaseUrl == null ? null : Uri.parse(databaseUrl);

  print('Setting up DB Connection...');
  final db = await Connection.open(
    Endpoint(
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
    ),
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );

  // set up migrations table
  print('Setting up migrations table ${argResults['table']}...');
  await db.execute('''
CREATE TABLE IF NOT EXISTS ${argResults['table']} (
  id SERIAL PRIMARY KEY,
  filename TEXT UNIQUE NOT NULL,
  applied_at TIMESTAMPTZ DEFAULT now()
);''');

  // run migrations on files in `sql`
  final dir = Directory(argResults['directory']);
  if (!(await dir.exists())) {
    stderr.writeln(
      'The directory at ${argResults['directory']} does not exist.',
    );
    exit(1);
  }

  print('Running migrations on files');
  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  // run migrations on each file
  for (final file in files) {
    final filename = p.basenameWithoutExtension(file.path);

    // check if file has already been migrated
    final hasBeenAppliedResult = await db.execute(
      Sql.named('''
SELECT (filename) FROM ${argResults['table']} WHERE filename = @filename;
'''),
      parameters: {'filename': filename},
    );

    if (hasBeenAppliedResult.isNotEmpty) continue;

    print('Applying migration from $filename');

    // read contents
    final contents = await file.readAsString();

    await db.runTx((session) async {
      await session.execute(contents, queryMode: QueryMode.simple);
      await session.execute(
        Sql.named('''
INSERT INTO ${argResults['table']} (filename) VALUES (@filename)
'''),
        parameters: {'filename': filename},
      );
    });
  }

  // close db
  print('Closing connection...');

  await db.close();

  print('All done!');
}

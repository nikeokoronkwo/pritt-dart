import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  group('Server Integration Test', () {
    final port = '8080';
    final host = 'http://0.0.0.0:$port';
    late Process p;
    late Process ofsService;
    late Process postgresService;

    setUpAll(() async {
      p = await Process.start(
        'dart',
        ['run', 'bin/server.dart'],
        environment: {'PORT': port},
      );

      // start other services

      // Wait for server to start and print to stdout.
      await p.stdout.first;
    });

    tearDownAll(() => p.kill());

    group('Adapter Calls', () {});

    group('API Calls', () {});

    group('API Workflows', () {});
  });
}

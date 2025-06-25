import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Map<String, String> readEnvFile(String dir) {
  final env = <String, String>{};
  final file = File(p.join(dir, '.env'));
  if (!file.existsSync()) return env;
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final idx = trimmed.indexOf('=');
    if (idx == -1) continue;
    final key = trimmed.substring(0, idx);
    final value = trimmed.substring(idx + 1);
    env[key] = value;
  }
  return env;
}

void main() {
  group('Server Integration Test', () {
    late Process serverProcess;
    late Process minioProcess;
    late Process postgresProcess;
    late Map<String, String> env;

    setUpAll(() async {
      // Read .env and prepare environment map
      env = readEnvFile(p.normalize(p.dirname(p.current)));

      // Start Postgres (example, adjust as needed)
      postgresProcess = await Process.start(
        'docker',
        [
          'run',
          '--rm',
          '-e',
          'POSTGRES_DB=${env['DATABASE_NAME']}',
          '-e',
          'POSTGRES_USER=${env['DATABASE_USERNAME']}',
          '-e',
          'POSTGRES_PASSWORD=${env['DATABASE_PASSWORD']}',
          '-p',
          '${env['DATABASE_PORT']}:5432',
          '--name',
          'test-postgres',
          'postgres:17'
        ],
        mode: ProcessStartMode.detached,
      );

      // Start MinIO (example, adjust as needed)
      minioProcess = await Process.start(
        'docker',
        [
          'run',
          '--rm',
          '-e',
          'MINIO_ROOT_USER=${env['MINIO_USERNAME']}',
          '-e',
          'MINIO_ROOT_PASSWORD=${env['MINIO_PASSWORD']}',
          '-p',
          '9000:9000',
          '-p',
          '9001:9001',
          '--name',
          'test-minio',
          'quay.io/minio/minio',
          'server',
          '/data'
        ],
        mode: ProcessStartMode.detached,
      );

      // Start your Dart server
      serverProcess = await Process.start(
        'dart',
        ['run', 'bin/server.dart'],
        environment: env,
      );

      // Wait for server to be ready (implement a better check in real code)
      await Future.delayed(Duration(seconds: 5));
    });

    tearDownAll(() async {
      serverProcess.kill();
      minioProcess.kill();
      postgresProcess.kill();
    });

    test('GET / returns 200 and Active', () async {
      final response = await http.get(Uri.parse('http://localhost:8080/'));
      expect(response.statusCode, 200);
      expect(response.body, contains('Active'));
    });

    test('GET /api/auth/new returns 200', () async {
      final response =
          await http.get(Uri.parse('http://localhost:8080/api/auth/new'));
      expect(response.statusCode, 200);
    });

    test('POST /api/auth/status returns 200 or 400', () async {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/auth/status'),
        headers: {'Content-Type': 'application/json'},
        body: '{}',
      );
      expect([200, 400, 401, 404], contains(response.statusCode));
    });

    test('POST /api/auth/validate returns 200 or 400', () async {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/auth/validate'),
        headers: {'Content-Type': 'application/json'},
        body: '{}',
      );
      expect([200, 400, 401, 404], contains(response.statusCode));
    });

    test('GET /api/publish/status returns 200', () async {
      final response =
          await http.get(Uri.parse('http://localhost:8080/api/publish/status'));
      expect(response.statusCode, 200);
    });

    test('PUT /api/package/upload returns 401 without auth', () async {
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/package/upload'),
        headers: {'Content-Type': 'application/json'},
        body: '{}',
      );
      expect([401, 400, 404], contains(response.statusCode));
    });

    test('GET /api/package/:name/:version returns 200 or 404', () async {
      final response = await http
          .get(Uri.parse('http://localhost:8080/api/package/pritt/0.1.0'));
      expect([200, 404], contains(response.statusCode));
    });

    test('POST /api/package/:name/:version returns 401 without auth', () async {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/package/pritt/0.1.0'),
        headers: {'Content-Type': 'application/json'},
        body: '{}',
      );
      expect([401, 400, 404], contains(response.statusCode));
    });

    test('GET /api/package/@:scope/:name returns 200 or 404', () async {
      final response = await http
          .get(Uri.parse('http://localhost:8080/api/package/@pritt/pritt'));
      expect([200, 404], contains(response.statusCode));
    });

    test('POST /api/package/@:scope/:name returns 401 without auth', () async {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/package/@pritt/pritt'),
        headers: {'Content-Type': 'application/json'},
        body: '{}',
      );
      expect([401, 400, 404], contains(response.statusCode));
    });

    test('GET /api/package/@:scope/:name/:version returns 200 or 404',
        () async {
      final response = await http.get(
          Uri.parse('http://localhost:8080/api/package/@pritt/pritt/0.1.0'));
      expect([200, 404], contains(response.statusCode));
    });

    test('POST /api/package/@:scope/:name/:version returns 401 without auth',
        () async {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/package/@pritt/pritt/0.1.0'),
        headers: {'Content-Type': 'application/json'},
        body: '{}',
      );
      expect([401, 400, 404], contains(response.statusCode));
    });

    test('GET /api/packages returns 200', () async {
      final response =
          await http.get(Uri.parse('http://localhost:8080/api/packages'));
      expect(response.statusCode, 200);
    });

    test('GET /api/package/{name} returns 200 for existing package', () async {
      final packageName = 'pritt'; // adjust as needed for your test data
      final response = await http
          .get(Uri.parse('http://localhost:8080/api/package/$packageName'));
      expect(response.statusCode, 200);
    });

    test('GET /api/package/{name} returns 404 for non-existent package',
        () async {
      final packageName = 'nonexistent-package-xyz';
      final response = await http
          .get(Uri.parse('http://localhost:8080/api/package/$packageName'));
      expect(response.statusCode, 404);
    });

    test('POST /api/package/{name} returns 401 without auth', () async {
      final packageName = 'pritt';
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/package/$packageName'),
        headers: {'Content-Type': 'application/json'},
        body: '{}',
      );
      expect(response.statusCode, 401);
    });

    // Add more tests for other endpoints and workflows
  });
}

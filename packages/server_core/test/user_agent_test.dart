import 'package:pritt_server_core/pritt_server_core.dart';
import 'package:test/test.dart';

final userAgentMaps = {
  'Dart pub 3.7.2': {'name': 'Dart pub', 'version': '3.7.2'},
  'pip/21.2.4 blah': {'name': 'pip', 'version': '21.2.4'},
  'pip/21.2.4 {"ci":null,"cpu":"arm64","distro":{"name":"macOS","version":"15.3.2"},"implementation":{"name":"CPython","version":"3.9.6"},"installer":{"name":"pip","version":"21.2.4"},"openssl_version":"LibreSSL 2.8.3","python":"3.9.6","rustc_version":"1.83.0","setuptools_version":"58.0.4","system":{"name":"Darwin","release":"24.3.0"}}':
      {'name': 'pip', 'version': '21.2.4'},
  'pnpm/9.15.2 npm/? node/v22.13.1 darwin arm64': {
    'name': 'pnpm',
    'version': '9.15.2',
  },
};

void main() {
  group('Version Tests', () {
    userAgentMaps.forEach((userAgentString, expected) {
      test('Parsing user agent: $userAgentString', () {
        final userAgent = UserAgent.fromRaw(userAgentString);
        expect(userAgent.name, equalsIgnoringCase(expected['name']!));
        expect(userAgent.version, equalsIgnoringCase(expected['version']!));
        expect(userAgent.toString(), equals(userAgentString));
      });
    });
  });
}

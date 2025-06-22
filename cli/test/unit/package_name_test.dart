import 'package:test/test.dart';
import 'package:pritt_cli/src/pkg_name.dart';

class PackageInfoTest {
  final String input;
  final String name;
  final String? scope;
  final String? version;
  const PackageInfoTest(this.input, this.name, {this.scope, this.version});

  @override
  bool operator ==(Object other) =>
      other is PackageInfoTest &&
      other.input == input &&
      other.name == name &&
      other.scope == scope &&
      other.version == version;

  @override
  int get hashCode => Object.hash(input, name, scope, version);
}

final packageInfoTests = <PackageInfoTest, Map<String, dynamic>>{
  PackageInfoTest('foo', 'foo'): {
    'name': 'foo',
    'scope': null,
    'version': null
  },
  PackageInfoTest('foo@1.2.3', 'foo', version: '1.2.3'): {
    'name': 'foo',
    'scope': null,
    'version': '1.2.3'
  },
  PackageInfoTest('@scope/foo', 'foo', scope: 'scope'): {
    'name': 'foo',
    'scope': 'scope',
    'version': null
  },
  PackageInfoTest('@scope/foo@2.0.0', 'foo', scope: 'scope', version: '2.0.0'):
      {'name': 'foo', 'scope': 'scope', 'version': '2.0.0'},
  PackageInfoTest('@scope/foo@2.0.0@beta', 'foo',
      scope: 'scope', version: '2.0.0@beta'): {
    'name': 'foo',
    'scope': 'scope',
    'version': '2.0.0@beta'
  },
  // More cases
  PackageInfoTest('bar@latest', 'bar', version: 'latest'): {
    'name': 'bar',
    'scope': null,
    'version': 'latest'
  },
  PackageInfoTest('@org/bar', 'bar', scope: 'org'): {
    'name': 'bar',
    'scope': 'org',
    'version': null
  },
  PackageInfoTest('@org/bar@dev', 'bar', scope: 'org', version: 'dev'): {
    'name': 'bar',
    'scope': 'org',
    'version': 'dev'
  },
  PackageInfoTest('baz@', 'baz', version: ''): {
    'name': 'baz',
    'scope': null,
    'version': ''
  },
};

void main() {
  group('parsePackageInfo', () {
    packageInfoTests.forEach((testObj, expected) {
      test('parsePackageInfo(\'${testObj.input}\')', () {
        final result = parsePackageInfo(testObj.input);
        expect(result.name, expected['name']);
        expect(result.scope, expected['scope']);
        expect(result.version, expected['version']);
      });
    });
  });
}

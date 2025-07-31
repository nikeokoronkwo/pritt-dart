import '../lib/version.dart';
import 'package:test/test.dart';

final versionTestMap = {
  '1.0.0': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': null,
    'build': null,
  },
  '1.0.0-alpha': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': 'alpha',
    'build': null,
  },
  '1.0.0+build': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': null,
    'build': 'build',
  },
  '1.0.0-alpha+build': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': 'alpha',
    'build': 'build',
  },
  '1.0.0-alpha.1': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': 'alpha.1',
    'build': null,
  },
  '1.0.0-alpha.1+build': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': 'alpha.1',
    'build': 'build',
  },
  '1.0.0-alpha.1+build.1': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': 'alpha.1',
    'build': 'build.1',
  },
  '1.0.0-alpha.1+build.1.2': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': 'alpha.1',
    'build': 'build.1.2',
  },
  '1.0.0-alpha.1+build.1.2.3': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': 'alpha.1',
    'build': 'build.1.2.3',
  },
  '2.0.5': {
    'major': 2,
    'minor': 0,
    'patch': 5,
    'preRelease': null,
    'build': null,
  },
  '2.0.5-alpha': {
    'major': 2,
    'minor': 0,
    'patch': 5,
    'preRelease': 'alpha',
    'build': null,
  },
  '3.1.2': {
    'major': 3,
    'minor': 1,
    'patch': 2,
    'preRelease': null,
    'build': null,
  },
  '3.1.2-beta': {
    'major': 3,
    'minor': 1,
    'patch': 2,
    'preRelease': 'beta',
    'build': null,
  },
  '4.2.0-rc': {
    'major': 4,
    'minor': 2,
    'patch': 0,
    'preRelease': 'rc',
    'build': null,
  },
  '5.0.0-dev': {
    'major': 5,
    'minor': 0,
    'patch': 0,
    'preRelease': 'dev',
    'build': null,
  },
  '6.0.0': {
    'major': 6,
    'minor': 0,
    'patch': 0,
    'preRelease': null,
    'build': null,
  },
  '0.0.1': {
    'major': 0,
    'minor': 0,
    'patch': 1,
    'preRelease': null,
    'build': null,
  },
  '0.1.0': {
    'major': 0,
    'minor': 1,
    'patch': 0,
    'preRelease': null,
    'build': null,
  },
  '0.1.0-alpha': {
    'major': 0,
    'minor': 1,
    'patch': 0,
    'preRelease': 'alpha',
    'build': null,
  },
  '1.0.0-0.3.7': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': '0.3.7',
    'build': null,
  },
  '1.0.0-x.7.z.92': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': 'x.7.z.92',
    'build': null,
  },
  '1.0.0-x-y-z.--1': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': 'x-y-z.--1',
    'build': null,
  },
  '1.0.0-1': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': '1',
    'build': null,
  },
  '1.0.0+20130313144700': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': null,
    'build': '20130313144700',
  },
  '1.0.0+20130313144700.123456': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': null,
    'build': '20130313144700.123456',
  },
  '1.0.0+20130313144700-123456': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': null,
    'build': '20130313144700-123456',
  },
  '0.0.1-alpha+exp.sha.5114f85': {
    'major': 0,
    'minor': 0,
    'patch': 1,
    'preRelease': 'alpha',
    'build': 'exp.sha.5114f85',
  },
  '1.0.0-alpha+exp.sha.5114f85': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': 'alpha',
    'build': 'exp.sha.5114f85',
  },
  '1.0.0+exp.sha.5114f85': {
    'major': 1,
    'minor': 0,
    'patch': 0,
    'preRelease': null,
    'build': 'exp.sha.5114f85',
  },
};

void main() {
  group('Version Tests', () {
    versionTestMap.forEach((versionString, expected) {
      test('Parsing version: $versionString', () {
        final version = Version.parse(versionString);
        expect(version.major, equals(expected['major']));
        expect(version.minor, equals(expected['minor']));
        expect(version.patch, equals(expected['patch']));
        expect(version.preRelease, equals(expected['preRelease']));
        expect(version.build, equals(expected['build']));
      });
    });
  });
}

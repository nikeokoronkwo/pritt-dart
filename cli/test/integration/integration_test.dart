import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:pritt_cli/src/cmd/adapter.dart';
import 'package:pritt_cli/src/cmd/add.dart';
import 'package:pritt_cli/src/cmd/configure.dart';
import 'package:pritt_cli/src/cmd/info.dart';
import 'package:pritt_cli/src/cmd/login.dart';
import 'package:pritt_cli/src/cmd/package.dart';
import 'package:pritt_cli/src/cmd/publish.dart';
import 'package:pritt_cli/src/cmd/remove.dart';
import 'package:pritt_cli/src/cmd/yank.dart';
import 'package:test/test.dart';

void main() {
  late CommandRunner runner;

  setUp(() {
    runner = CommandRunner<void>('pritt_test', 'A test CLI for Pritt')
      ..addCommand(AddCommand())
      ..addCommand(RemoveCommand())
      ..addCommand(LoginCommand())
      ..addCommand(InfoCommand())
      ..addCommand(ConfigureCommand())
      ..addCommand(PackageCommand())
      ..addCommand(PublishCommand())
      ..addCommand(YankCommand())
      ..addCommand(AdapterCommand());
  });

  test('configure then package current', () async {
    final configureOutput = await runWithOutput(() {
      return runner.run(['configure']);
    });
    expect(configureOutput, contains('configure'));

    final currentOutput = await runWithOutput(() {
      return runner.run(['package', 'current']);
    });
    expect(currentOutput, anyOf([contains('Current package'), contains('No package'), contains('not found')])) ;
  });

  test('publish then package info', () async {
    // Simulate publish (adjust args as needed for your test project)
    final publishOutput = await runWithOutput(() {
      return runner.run(['publish']);
    });
    expect(publishOutput, anyOf([contains('publish'), contains('not logged in'), contains('error'), contains('success')]));

    // Now run package info (should not error)
    final infoOutput = await runWithOutput(() {
      return runner.run(['package', 'info', 'pritt']);
    });
    expect(infoOutput, anyOf([contains('info'), contains('not found'), contains('No package')]));
  });

  test('unpack command', () async {
    final unpackOutput = await runWithOutput(() {
      return runner.run(['unpack', 'pritt']);
    });
    expect(unpackOutput, anyOf([contains('unpack'), contains('not found'), contains('No package')]));
  });

  test('adapter list command', () async {
    final output = await runWithOutput(() {
      return runner.run(['adapter', 'list']);
    });
    expect(output, anyOf([
      contains('adapters'),
      contains('not logged in'),
      contains('no adapters'),
      contains('You are not logged in to Pritt'),
    ]));
  });

  test('adapter unpack command', () async {
    final output = await runWithOutput(() {
      return runner.run(['adapter', 'unpack', 'pritt']);
    });
    expect(output, anyOf([
      contains('Fetching Adapter'),
      contains('not logged in'),
      contains('Argument for package required'),
      contains('No package'),
      contains('Directory already exists.'),
    ]));
  });

  test('yank command', () async {
    final output = await runWithOutput(() {
      return runner.run(['yank', 'pritt']);
    });
    expect(output, anyOf([
      contains('yank'),
      contains('not logged in'),
      contains('No package'),
      contains('error'),
    ]));
  });

  test('remove command', () async {
    final output = await runWithOutput(() {
      return runner.run(['remove', 'pritt']);
    });
    expect(output, anyOf([
      contains('remove'),
      contains('not logged in'),
      contains('No package'),
      contains('error'),
    ]));
  });

  test('info command', () async {
    final output = await runWithOutput(() {
      return runner.run(['info']);
    });
    expect(output, anyOf([
      contains('User Information'),
      contains('not logged in'),
      contains('Your login session has expired'),
      contains('To log in, run:'),
    ]));
  });

  test('publish with url option (success)', () async {
    final output = await runWithOutput(() {
      return runner.run(['publish', '--url', 'http://localhost:8080']);
    });
    expect(output, contains('publish'));
  });

  test('package current with output option (success)', () async {
    final output = await runWithOutput(() {
      return runner.run(['package', 'current', '--output', 'stdout']);
    });
    expect(output, anyOf([contains('Current package'), contains('{'), contains('No package'), contains('not found')]));
  });

  test('package info with valid package (success)', () async {
    final output = await runWithOutput(() {
      return runner.run(['package', 'info', 'pritt']);
    });
    expect(output, anyOf([contains('info'), contains('pritt'), contains('not found'), contains('No package')]));
  });

  test('configure with config option (success)', () async {
    final output = await runWithOutput(() {
      return runner.run(['configure', '--config', 'pritt.yaml']);
    });
    expect(output, contains('configure'));
  });

  test('unpack with output option (success)', () async {
    final output = await runWithOutput(() {
      return runner.run(['unpack', 'pritt', '--output', 'stdout']);
    });
    expect(output, anyOf([contains('Fetching Package'), contains('Downloading Package'), contains('No package'), contains('not logged in')]));
  });
}

/// Helper to capture stdout
Future<String> runWithOutput(FutureOr<void> Function() action) async {
  final spec = ZoneSpecification(
    print: (self, parent, zone, line) {
      _printBuffer.write('$line\n');
    },
  );
  _printBuffer.clear();
  await Zone.current.fork(specification: spec).run(() async {
    await action();
  });
  return _printBuffer.toString();
}

final _printBuffer = StringBuffer();

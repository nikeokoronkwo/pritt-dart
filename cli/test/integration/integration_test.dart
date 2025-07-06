import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:pritt_cli/src/cli/base.dart';
import 'package:pritt_cli/src/cmd/adapter.dart';
import 'package:pritt_cli/src/cmd/add.dart';
import 'package:pritt_cli/src/cmd/configure.dart';
import 'package:pritt_cli/src/cmd/info.dart';
import 'package:pritt_cli/src/cmd/login.dart';
import 'package:pritt_cli/src/cmd/package.dart';
import 'package:pritt_cli/src/cmd/publish.dart';
import 'package:pritt_cli/src/cmd/remove.dart';
import 'package:pritt_cli/src/cmd/unpack.dart';
import 'package:pritt_cli/src/cmd/yank.dart';
import 'package:test/test.dart';

void main() {
  late CommandRunner runner;

  setUp(() {
    runner = PrittCommandRunner('pritt_test', 'A test CLI for Pritt')
      ..addCommand(AddCommand())
      ..addCommand(RemoveCommand())
      ..addCommand(LoginCommand())
      ..addCommand(InfoCommand())
      ..addCommand(ConfigureCommand())
      ..addCommand(UnpackCommand())
      ..addCommand(PackageCommand())
      ..addCommand(PublishCommand())
      ..addCommand(YankCommand())
      ..addCommand(AdapterCommand());
  });

  test('Basic', () async {
    final _ = await runWithOutput(() {
      return runner.run([]);
    });
  }, skip: 'Unimplemented');
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

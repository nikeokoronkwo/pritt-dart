import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:pritt_cli/src/utils/log.dart';
import 'package:pritt_cli/src/utils/run.dart';

abstract class PrittCommand<U> extends Command<U> {
  /// Whether the given command is verbose or not
  bool get verbose => (runner as PrittCommandRunner).verbose;

  /// A generic logger for logging to stdout
  Logger get logger => verbose ? Logger.verbose() : Logger();
}

final Runner rootRunner = Runner();

/// Special Implementation of the [CommandRunner] class for the Devenv CLI to provide global flags
///
/// Implements other functionality such as the version
class PrittCommandRunner extends CommandRunner {
  /// The pheasant version
  final String version;

  /// Whether verbose or not
  bool verbose = false;

  PrittCommandRunner(super.executableName, super.description,
      {this.version = "0.1.0"})
      : super() {
    argParser
      ..addFlag('version',
          abbr: 'v',
          negatable: false,
          help: "Print out the current devenv version")
      ..addFlag('verbose',
          abbr: 'V', negatable: false, help: "Output Verbose Logging");
    // ..addFlag('define', abbr: 'D', help: 'Define overrides to given config options');
  }

  @override
  Future run(Iterable<String> args) {
    if (args.contains('--version') || args.contains('-v')) {
      return Future.sync(() => print('devenv version $version'));
    }
    if (args.contains('--verbose') || args.contains('-V')) {
      verbose = true;
    }
    return super.run(args);
  }
}

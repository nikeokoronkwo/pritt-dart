import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:pritt_cli/src/cmd/unpack/adapter.dart';
import 'package:pritt_cli/src/cmd/unpack/package.dart';

import '../cli/base.dart';

class UnpackCommand extends PrittCommand {
  @override
  String name = "unpack";

  @override
  String description =
      "Get a package locally and make modifications to the package";

  UnpackCommand() {
    addSubcommand(UnpackPackageCommand());
    addSubcommand(UnpackAdapterCommand());
  }

  @override
  FutureOr? run() {
    // get arguments
    if ((argResults?.rest ?? []).isEmpty) {
      logger.stderr("Argument for package required");
      throw UsageException("Argument for package required", usage);
    }

    final argument = argResults!.rest.first;
    final [packageName, ...versionArgs] = argument.split('@');
    final version = versionArgs.isEmpty ? 'latest' : versionArgs[0];
    // check if user is logged in

    // get archive of package
  }
}

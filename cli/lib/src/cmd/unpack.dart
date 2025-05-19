import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/io.dart';

import '../cli/base.dart';

class UnpackCommand extends PrittCommand {
  @override
  String name = "unpack";

  @override
  String description =
      "Get a package locally and make modifications to the package";

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

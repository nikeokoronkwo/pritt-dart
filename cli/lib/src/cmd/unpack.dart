import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';
import 'package:pritt_cli/src/client.dart';
import 'package:pritt_cli/src/package.dart';
import 'package:pritt_cli/src/user_config.dart';

import '../cli/base.dart';

class UnpackCommand extends PrittCommand {
  @override
  String name = "unpack";

  @override
  String description =
      "Get a package locally and make modifications to the package";

  @override
  List<String> get aliases => ['package unpack'];

  @override
  Future<void> run() async {
    // get arguments
    if ((argResults?.rest ?? []).isEmpty) {
      logger.stderr("Argument for package required");
      throw UsageException("Argument for package required", usage);
    }

    final argument = argResults!.rest.first;
    final (name: name, scope: scope, version: version) = parsePackageInfo(argument);

    // check if user is logged in
    var userCredentials = await UserCredentials.fetch();

    if (userCredentials == null || userCredentials.isExpired) {
      // if user not logged in, tell user to log in
      logger.severe(userCredentials == null
          ? 'You are not logged in to Pritt'
          : 'Your login session has expired');
      logger.severe('To log in, run: ${styleBold.wrap('pritt login')}');
      exit(1);
    }

    // establish client
    final client = PrittClient(
        url: userCredentials.uri.toString(),
        accessToken: userCredentials.accessToken);

    // get archive of package
    // final content = client.get
  }
}

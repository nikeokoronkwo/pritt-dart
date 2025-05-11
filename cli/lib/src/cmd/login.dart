import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:pritt_cli/src/constants.dart';
import 'package:pritt_cli/src/user_config.dart';
import 'package:pritt_cli/src/utils/extensions.dart';

import '../cli/base.dart';

class LoginCommand extends PrittCommand {
  @override
  String name = "login";

  @override
  String description = "Login to the Pritt Server";

  LoginCommand() {
    argParser..addOption('url',
        abbr: 'u',
        help:
            "The URL of the pritt server. Defaults to the main pritt instance (you can also just pass 'main' to indicate the main server)",
        valueHelp: 'url')
    ..addFlag('headless', negatable: false, defaultsTo: false, help: 'Run login on the CLI. Defaults to false (launch browser)');
  }

  @override
  FutureOr? run() async {
    // get arguments
    String? url = argResults!['url'];

    // validate arguments
    if (url != null) {
      if (url == 'main') {
        url = mainPrittInstance;
      } else if (!url.isUrl) {
        throw UsageException("'url' option must be valid URL", usage);
      }
    }

    // check if user is logged in
    var userCredentials = await UserCredentials.fetch();

    if (userCredentials != null) {
      // else log user in
    } else {
      // if user is logged in, state that user is logged in
    }

    // get user info from login details

    // display user log in info
  }
}

import 'dart:async';
import 'dart:io';

import 'package:io/ansi.dart';

import '../cli/base.dart';
import '../config/user_config.dart';

class ServerCommand extends PrittCommand {
  @override
  String name = "server";

  @override
  String description = "Get information about the Pritt instance connected to";

  ServerCommand();

  @override
  FutureOr? run() async {
    // check if user is logged in
    var userCredentials = await UserCredentials.fetch();

    if (userCredentials == null || userCredentials.isExpired) {
      // if user not logged in, tell user to log in
      logger.severe(
        userCredentials == null
            ? 'You are not logged in to Pritt'
            : 'Your login session has expired',
      );
      logger.stderr('To log in, run: ${styleBold.wrap('pritt login')}');
      exit(1);
    }

    logger.stdout('Server Instance: ${userCredentials.uri}');
    exit(0);
  }
}

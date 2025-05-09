import 'dart:async';


import '../cli/base.dart';

class LoginCommand extends PrittCommand {
  @override
  String name = "login";

  @override
  String description = "Login to the Pritt Server";

  LoginCommand() {
    argParser.addOption('url',
        abbr: 'u',
        help:
            "The URL of the pritt server. Defaults to the main pritt instance");
  }

  @override
  FutureOr? run() {
    // check if user is logged in

    // if user is logged in, state that user is logged in

    // else log user in

    // display user log in info
  }
}

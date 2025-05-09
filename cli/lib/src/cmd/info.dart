import 'dart:async';

import '../cli/base.dart';

class InfoCommand extends PrittCommand {
  @override
  String name = "info";

  @override
  String description =
      "Get current information about the currently logged in user";

  @override
  FutureOr? run() {
    // check if user is logged in

    // if user not logged in, tell user to log in

    // if user is logged in, get user info

    // print user info as table
  }
}

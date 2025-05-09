import 'dart:async';


import '../cli/base.dart';

class YankCommand extends PrittCommand {
  @override
  String name = "yank";

  @override
  String description = "Yank ('remove') a package from Pritt";

  @override
  FutureOr? run() {
    // get package name to remove

    // get user info if logged in

    // check for package availability /api/package/{name}

    // if package available, yank
  }
}

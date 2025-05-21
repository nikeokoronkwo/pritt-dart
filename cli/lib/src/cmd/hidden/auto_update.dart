import 'dart:async';

import 'package:args/command_runner.dart';

class UpdateCommand extends Command {
  @override
  bool hidden = true;

  @override
  String name = "update";

  @override
  // TODO: find which installation of pritt this is
  String get description =>
      "Checks for any updates of pritt based on the installation of Pritt present";

  UpdateCommand() {}

  @override
  FutureOr? run() {
    // TODO: implement run
    return super.run();
  }
}

import 'dart:async';

import 'package:args/command_runner.dart';

class UpdateCommand extends Command {
  @override
  bool hidden = true;

  @override
  String name = "update";

  @override
  String get description =>
      "Checks for any updates of pritt based on the installation of Pritt present";

  UpdateCommand();

  @override
  FutureOr? run() {
    // TODO(nikeokoronkwo): implement auto_update, https://github.com/nikeokoronkwo/pritt-dart/issues/60
    return super.run();
  }
}

import 'dart:async';

import 'package:args/command_runner.dart';

class ServerCommand extends Command {
  @override
  String name = "server";

  @override
  String description = "Get information about the Pritt instance connected to";

  ServerCommand();

  @override
  FutureOr? run() {
    // TODO: implement run
  }
}

import 'dart:async';


import '../cli/base.dart';

class ConfigureCommand extends PrittCommand {
  @override
  String name = "configure";

  @override
  String description =
      "Configures your project to be able to use its own package manager for installing packages from Pritt";

  @override
  FutureOr? run() {
    
  }
}

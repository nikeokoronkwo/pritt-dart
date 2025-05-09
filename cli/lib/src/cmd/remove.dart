import 'dart:async';


import '../cli/base.dart';

class RemoveCommand extends PrittCommand {
  @override
  String name = "remove";

  @override
  String description = "Uninstall a pritt package";

  @override
  List<String> aliases = ["uninstall"];

  @override
  FutureOr? run() {
    // basically run everything in configure if not already there

    // run the package manager's remove
  }
}

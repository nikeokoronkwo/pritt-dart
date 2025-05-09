import 'dart:async';

import '../cli/base.dart';

class AddCommand extends PrittCommand {
  @override
  String name = "add";

  @override
  String description = "Install a pritt package";

  @override
  List<String> aliases = ["install"];

  @override
  FutureOr? run() {
    // basically run everything in configure if not already there

    // run the package manager's add
  }
}

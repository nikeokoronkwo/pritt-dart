import 'dart:async';


import 'package/current.dart';
import 'package/list.dart';

import '../cli/base.dart';

class PackageCommand extends PrittCommand {
  @override
  String name = "package";

  @override
  String description = "Information about packages in Pritt";

  PackageCommand() {
    addSubcommand(PackageCurrentCommand());
    addSubcommand(PackageListCommand());
  }

  @override
  FutureOr? run() {}
}

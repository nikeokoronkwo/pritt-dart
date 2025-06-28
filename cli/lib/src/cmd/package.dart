import 'dart:async';

import '../cli/base.dart';
import 'package/current.dart';
import 'package/list.dart';
import 'package/publish.dart';
import 'package/unpack.dart';

class PackageCommand extends PrittCommand {
  @override
  String name = "package";

  @override
  String description = "Information about packages in Pritt";

  PackageCommand() {
    addSubcommand(PackageCurrentCommand());
    addSubcommand(PackageListCommand());
    addSubcommand(PackageUnpackCommand());
    addSubcommand(PackagePublishCommand());
  }

  @override
  FutureOr? run() {}
}

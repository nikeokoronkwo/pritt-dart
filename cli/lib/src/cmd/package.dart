import 'dart:async';

import 'package:pritt_cli/src/cmd/package/publish.dart';
import 'package:pritt_cli/src/cmd/package/unpack.dart';

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
    addSubcommand(PackageUnpackCommand());
    addSubcommand(PackagePublishCommand());
  }

  @override
  FutureOr? run() {}
}

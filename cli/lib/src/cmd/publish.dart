import 'dart:async';

import 'package:pritt_cli/src/cmd/publish/adapter.dart';
import 'package:pritt_cli/src/cmd/publish/package.dart';

import '../cli/base.dart';

class PublishCommand extends PrittCommand {
  @override
  String name = "publish";

  @override
  String description = "Publish a package to Pritt";

  PublishCommand() {
    addSubcommand(PublishPackageCommand());
    addSubcommand(PublishAdapterCommand());
  }

  @override
  FutureOr? run() {
    // get information about current package information

    // get user information and

    // if no user information, log user in

    // get package metadata

    // receive package id and other stuff

    // validate that user wants to publish package

    // zip package

    // publish user package with id
  }
}

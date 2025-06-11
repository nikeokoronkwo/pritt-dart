import 'dart:async';

import '../cli/base.dart';

class PublishCommand extends PrittCommand {
  @override
  String name = "publish";

  @override
  String description = "Publish a package to Pritt";

  PublishCommand() {
    argParser
      ..addOption('config',
          abbr: 'c',
          help:
              'The Pritt Configuration File (defaults to pritt.yaml file if exists)')
      ..addOption('project-config',
          help:
              'The Project Configuration file to use (defaults to handler inference)');
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

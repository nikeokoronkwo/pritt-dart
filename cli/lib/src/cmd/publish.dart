import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:io/ansi.dart';
import 'package:path/path.dart' as p;

import 'package:pritt_cli/src/client.dart';
import 'package:pritt_cli/src/user_config.dart';
import 'package:pritt_cli/src/workspace.dart';

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
  FutureOr? run() async {
    // check if user is logged in
    var userCredentials = await UserCredentials.fetch();

    if (userCredentials == null || userCredentials.isExpired) {
      // if user not logged in, tell user to log in
      logger.severe(userCredentials == null
          ? 'You are not logged in to Pritt'
          : 'Your login session has expired');
      logger.severe('To log in, run: ${styleBold.wrap('pritt login')}');
      exit(1);
    }

    // set up client
    var prittClient = (userCredentials == null || userCredentials.isExpired)
        ? null
        : PrittClient(
        url: userCredentials.uri.toString(),
        accessToken: userCredentials.accessToken);

    // get information about current package information
    logger.stdout('Going through project...');
    var project = await getWorkspace(p.current,
        config: argResults?['config'], client: prittClient);
    if (project.handlers.isNotEmpty) {
      logger.info('Found: ${project.handlers.join(', ')}!');
    }

    // get package metadata

    // receive package id and other stuff

    // validate that user wants to publish package

    // zip package

    // publish user package with id
  }
}

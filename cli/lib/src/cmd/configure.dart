import 'dart:async';
import 'dart:io';

import 'package:io/ansi.dart';
import 'package:path/path.dart' as p;
import '../cli/base.dart';
import '../client.dart';
import '../user_config.dart';
import '../workspace.dart';

class ConfigureCommand extends PrittCommand {
  @override
  String name = "configure";

  @override
  String description =
      "Configures your project to be able to use its own package manager for installing packages from Pritt";

  ConfigureCommand() {
    argParser.addOption('config',
        abbr: 'c',
        help:
            'The Pritt Configuration file for this project. Defaults to the "pritt.yaml" file in the current directory',
        defaultsTo: "pritt.yaml");
  }

  @override
  Future<void> run() async {
    // check if user is logged in
    var userCredentials = await UserCredentials.fetch();

    if (userCredentials == null || userCredentials.isExpired) {
      // if user not logged in, tell user to log in
      logger.warn(userCredentials == null
          ? 'You are not logged in to Pritt'
          : 'Your login session has expired');
      logger.warn('To log in, run: ${styleBold.wrap('pritt login')}');
    }

    var prittClient = (userCredentials == null || userCredentials.isExpired)
        ? null
        : PrittClient(
            url: userCredentials.uri.toString(),
            accessToken: userCredentials.accessToken);

    // get project
    logger.stdout('Getting Adapter for Project...');
    var project = await getProject(p.current,
        config: argResults?['config'], client: prittClient);
    if (project.handlers.isEmpty) {
      logger.warn('Could not find a suitable handler for the given project.');
      // TODO: Links to go to
      logger.verbose(
          'Try installing a handler for the project type from the marketplace, or filing an issue to add support/fix this (if you think it is a bug)');
      exit(1);
    } else {
      logger.info('Found: ${project.handlers.join(', ')}!');
    }

    // configure project
    logger.info('Configuring Project...');
    await project.configure();

    logger.fine('All Done!');
    logger.fine(
        'You can now use basic commands for installing and uninstalling packages');
  }
}

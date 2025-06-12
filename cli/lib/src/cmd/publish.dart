import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart' as p;

import '../cli/base.dart';
import '../client.dart';
import '../constants.dart';
import '../login.dart';
import '../user_config.dart';
import '../utils/extensions.dart';
import '../workspace.dart';

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
      ..addOption('url',
          abbr: 'u',
          help:
              "The URL of the pritt server. Defaults to the main pritt instance (you can also just pass 'main' to indicate the main server).\n"
              "By default, if this is not a local instance of pritt, or 'main', an 'api' prefix will be placed in front of this URL\nif not specified already, and omitted for the Client URL.\n"
              "To prevent this default behaviour, you can specify the client URL using the '--client-url' option.",
          valueHelp: 'url')
      ..addOption('client-url',
          valueHelp: 'url',
          help:
              "The URL of the pritt client. Defaults to the main pritt instance (you can also just pass 'main' to indicate the main server).\nUse this only when you need to specify a separate URL for the client, like when using on a local instance.",
          aliases: ['client'])
      ..addOption('project-config',
          help:
              'The Project Configuration file to use (defaults to handler inference)')
      ..addOption('language', abbr: 'l',
      help: 'If project contains multiple languages, this specifies the primary language to publish/select handlers for.');
  }

  @override
  FutureOr? run() async {
    // get arguments
    String? url = argResults?['url'];
    String? clientUrl = argResults?['client-url'];

    // validate arguments
    if (url != null) {
      if (url == 'main') {
        url = mainPrittApiUrl.toString();
      } else if (!url.isUrl) {
        throw UsageException("'url' option must be valid URL", usage);
      }
    } else {
      url = mainPrittApiUrl.toString();
    }

    if (clientUrl != null) {
      if (clientUrl == 'main') {
        clientUrl = mainPrittInstance;
      } else if (!clientUrl.isUrl) {
        throw UsageException("'client-url' option must be valid URL", usage);
      }
    } else {
      clientUrl = mainPrittInstance;
    }

    final client = PrittClient(url: url);

    // check if user is logged in
    var userCredentials = await UserCredentials.fetch();

    if (userCredentials == null || userCredentials.isExpired) {
      // if user not logged in, log him in
      userCredentials = await loginUser(client, clientUrl, logger);
      await userCredentials.update();
    }

    // close login client - we need auth for next steps
    client.close();

    // set up new client client
    var prittClient = PrittClient(
        url: userCredentials.uri.toString(),
        accessToken: userCredentials.accessToken);

    // get information about current package information
    logger.stdout('Going through project...');
    var project = await getWorkspace(p.current,
        config: argResults?['config'], client: prittClient);

    // check for a handler to use
    if (project.handlers.isEmpty) {
      logger.severe('Could not find a suitable handler for the given project.');
      // TODO: Links to go to
      logger.stderr('Try installing a handler for the project type from the marketplace, or filing an issue to add support/fix this (if you think it is a bug)');
      exit(1);
    } else {
      // get an active handler
      if (argResults?.wasParsed('language') ?? false) {
        // check for handler for language
        try {
          final langHandler = project.handlers.firstWhere((l) => l.language == argResults!['language']);
          project.primaryHandler = langHandler;
        } on StateError catch (e) {
          logger.severe('Could not find any adapters matching the given language ${argResults!['language']}');
          logger.verbose(e.message);
          exit(1);
        }
      } else {
        // check if single
        try {
          project.primaryHandler = project.handlers.single;
        } on StateError catch (e) {
          logger.severe('Found more than one handler matching the given project.');
          for (var h in project.handlers) {
            logger.stderr('\t- ${h.language}');
          }
          logger.stderr('You will need to pick one by rerunning this with the "--language" flag');
          logger.verbose(e.message);
          throw UsageException('', usage);
        }
      }
    }



    // get package metadata
    final metadata = project.getEnv();

    // send publish initiate request to endpoint

    // receive and write endpoint pub request

    // while endpoint is being listened to: wait

    // receive package id and other stuff

    // validate that user wants to publish package

    // once completed auth,

    // zip package

    // publish user package with id
  }
}

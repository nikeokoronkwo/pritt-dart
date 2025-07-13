import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:io/ansi.dart';
import 'package:path/path.dart' as p;
import 'package:pritt_common/interface.dart';

import '../../cli/base.dart';
import '../../client.dart';
import '../../config/user_config.dart';
import '../../table_output.dart';
import '../../workspace/workspace.dart';

class PackageCurrentCommand extends PrittCommand {
  @override
  String name = "current";

  @override
  String description = "Get information about the current package if on pritt";

  PackageCurrentCommand() {
    argParser.addOption(
      'json',
      help:
          'Write as a JSON output to a file. Pass "stdout" to print the JSON to stdout',
      valueHelp: 'file',
    );
  }

  @override
  FutureOr? run() async {
    // check if user is logged in
    final userCredentials = await UserCredentials.fetch();

    if (userCredentials == null || userCredentials.isExpired) {
      // if user not logged in, tell user to log in
      logger.warn(
        userCredentials == null
            ? 'You are not logged in to Pritt'
            : 'Your login session has expired',
      );
      logger.warn('To log in, run: ${styleBold.wrap('pritt login')}');
    }

    final prittClient = (userCredentials == null || userCredentials.isExpired)
        ? null
        : PrittClient(
            url: userCredentials.uri.toString(),
            accessToken: userCredentials.accessToken,
          );

    // get project
    logger.stdout('Getting Adapter for Project...');
    final project = await getProject(
      p.current,
      config: argResults?['config'],
      client: prittClient,
    );
    if (project.handlers.isEmpty) {
      logger.warn('Could not find a suitable handler for the given project.');
      logger.verbose(
        'Try installing a handler for the project type from the marketplace, or filing an issue to add support/fix this (if you think it is a bug)',
      );
      exit(1);
    } else {
      logger.info('Found: ${project.handlers.join(', ')}!');
    }

    // provide package information
    if (argResults?.wasParsed('json') ?? false) {
      final config = await project.getWorkspace();

      // json output
      final projectJson = {
        'name': config.name,
        'language': project.primaryHandler.language,
        if (config.packageManager?.name case final pm?) 'package manager': pm,
        if (project.vcs != VCS.other) 'vcs': project.vcs.name,
      };

      await File(
        argResults?['json'] ?? 'results.json',
      ).writeAsString(jsonEncode(projectJson));
    } else {
      logger.info('Info for project at ${project.directory}');
      // table output
      logger.stdout(await listProjectInfo(project));
    }
  }
}

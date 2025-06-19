import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart' as p;
import 'package:pritt_common/functions.dart';

import '../adapters/base/workspace.dart';
import '../cli/base.dart';
import '../client.dart';
import '../pkg_name.dart';
import '../user_config.dart';
import '../utils/extensions.dart';
import '../workspace.dart';

class AddCommand extends PrittCommand {
  @override
  String name = "add";

  @override
  String description = "Install a pritt package";

  @override
  List<String> aliases = ["install"];

  @override
  bool get hidden => true;

  AddCommand() {
    argParser
      ..addFlag('configure',
          negatable: true,
          help: 'Whether to configure the project before running this command',
          defaultsTo: true)
      ..addFlag('dev', abbr: 'D', negatable: false, help: 'Add dev dependency');
  }

  // TODO: We should track if certain assets are already generated, if not
  @override
  FutureOr? run() async {
    // arg resolution
    final restArgs = argResults?.rest ?? [];
    if (restArgs.isEmpty) {
      throw UsageException('At least one argument is needed', usage);
    }

    logger.warn('For best results, use your language package manager if any');

    // basically run everything in configure if not already there
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
    var project = await getWorkspace(p.current,
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

    if (argResults?['configure'] ?? true) {
      logger.info('Configuring Project...');
      await project.configure();
    }

    if (project.primaryHandler.packageManager == null) {
      logger.severe(
          '${styleBold.wrap('Error')}: The given language ${project.primaryHandler.language} does not have a package maanger to run');
      exit(2);
    }

    // run the package manager's add
    final packages = restArgs.map(parsePackageInfo);
    var type = argResults?.wasParsed('dev') ?? false
        ? PackageType.dev
        : PackageType.normal;

    final packageCommands = project.primaryHandler.packageManager!.onAdd();

    final cmds = <List<String>>[];

    if (packages.isSingle) {
      // collation shouldnt matter
    } else {
      final firstArg = packages.first;
      // try to collate
      final pkgAddInfo = packageCommands.resolveType(
          packageCommands.resolveVersion(firstArg.name, firstArg.version),
          type);
      if (pkgAddInfo.collate ?? false) {
        // collate add into one arg afterwards
        final cmdsToAdd = pkgAddInfo.$1..removeLast();
      }
    }

    // TODO: Links to go to
    logger.stderr(
        'This command is under maintenance at this point. Please file a bug with us');

    //   final pc = packages.map((info) {

    //       final cmd = project.primaryHandler.packageManager!.onAdd();

    //       final resolvedNameAndTypeArgs = cmd.resolveType(cmd.resolveVersion(info.name, info.version), type);
    //       final resolvedUrlArgs = (cmd.resolveUrl ?? ((name, url) => ([name], singleUse: true)))(resolvedNameAndTypeArgs.last, prittClient?.url);
    //       if (resolvedUrlArgs.$1.isSingle) {
    //         resolvedNameAndTypeArgs.last = resolvedUrlArgs.$1.single;
    //       } else {
    //         resolvedNameAndTypeArgs.removeLast();
    //         resolvedNameAndTypeArgs.addAll(resolvedUrlArgs.$1);
    //       }
    //       return [
    //         ...cmd.args,
    //         ...resolvedNameAndTypeArgs
    //       ];
    //     });
  }
}

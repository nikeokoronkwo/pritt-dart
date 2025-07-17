import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';
import '../cli/base.dart';
import '../client.dart';
import '../config/user_config.dart';

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
      ..addFlag(
        'configure',
        negatable: true,
        help: 'Whether to configure the project before running this command',
        defaultsTo: true,
      )
      ..addFlag('dev', abbr: 'D', negatable: false, help: 'Add dev dependency');
  }

  // TODO(nikeokoronkwo): We should track if certain assets are already generated, if not, https://github.com/nikeokoronkwo/pritt-dart/issues/54
  // TODO(nikeokoronkwo): Implement `pritt add`, https://github.com/nikeokoronkwo/pritt-dart/issues/53
  @override
  FutureOr? run() async {
    // arg resolution
    final restArgs = argResults?.rest ?? [];
    if (restArgs.isEmpty) {
      throw UsageException('At least one argument is needed', usage);
    }

    logger.warn('For best results, use your language package manager if any');

    // basically run everything in configure if not already there
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

    var _ = (userCredentials == null || userCredentials.isExpired)
        ? null
        : PrittClient(
            url: userCredentials.uri.toString(),
            accessToken: userCredentials.accessToken,
          );

    logger.stderr(
      'This command is under maintenance at this point. Please file a bug with us',
    );
  }
}

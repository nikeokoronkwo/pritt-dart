import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';
import 'package:pritt_cli/src/cli/progress_bar.dart';
import 'package:pritt_cli/src/client.dart';
import 'package:pritt_cli/src/package.dart';
import 'package:pritt_cli/src/user_config.dart';

import '../cli/base.dart';

class UnpackCommand extends PrittCommand {
  @override
  String name = "unpack";

  @override
  String description =
      "Get a package locally and make modifications to the package";

  @override
  List<String> get aliases => ['unpack'];

  UnpackCommand() {
    argParser
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Overwrite the target directory if it already exists.',
      )
      ..addOption('output',
          abbr: 'o', help: 'The output directory to write this to');
  }

  @override
  Future<void> run() async {
    // get arguments
    if ((argResults?.rest ?? []).isEmpty) {
      logger.stderr("Argument for package required");
      throw UsageException("Argument for package required", usage);
    }

    final argument = argResults!.rest.first;
    final (name: name, scope: scope, version: version) =
        parsePackageInfo(argument);

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

    // establish client
    final client = PrittClient(
        url: userCredentials.uri.toString(),
        accessToken: userCredentials.accessToken);

    // get archive of package
    final content = await client.getPackageArchiveWithName(
        name: scope != null ? '@$scope/$name}' : name, version: version);

    final contentLength = content.length;

    final ProgressBar progressBar = ProgressBar('Downloading Package',
        completeMessage: 'Package Downloaded');

    final File tarFile =
        await File((argResults?['output'] ?? name) + '.tar.gz').create();
    final sink = tarFile.openWrite();

    int bytesReceived = 0;

    final completer = Completer<void>();

    content.data.listen(
      (chunk) {
        sink.add(chunk);
        bytesReceived += chunk.length;
        progressBar.tick(bytesReceived, contentLength);
      },
      onDone: () async {
        await sink.close();
        progressBar.end();
        completer.complete();
      },
      onError: (e, st) async {
        await sink.close();
        completer.completeError(e, st);
      },
      cancelOnError: true,
    );

    await completer.future;

    // now deflate, and open
    // TODO: Complete
  }
}

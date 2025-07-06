import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';
import '../../archive.dart';
import '../../cli/base.dart';
import '../../cli/progress_bar.dart';
import '../../client.dart';
import '../../config/user_config.dart';

class AdapterUnpackCommand extends PrittCommand {
  @override
  String get name => "unpack";

  @override
  String get description => "Downloads an adapter from Pritt to use in-place";

  @override
  String get invocation => 'pritt adapter unpack <name> [flags]';

  AdapterUnpackCommand() {
    argParser
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Overwrite the target directory if it already exists.',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'The output directory to write this to',
      );
  }

  @override
  Future<void> run() async {
    // get arguments
    if ((argResults?.rest ?? []).isEmpty) {
      logger.stderr("Argument for package required");
      throw UsageException("Argument for package required", usage);
    }

    final name = argResults!.rest.first;

    // check if user is logged in
    var userCredentials = await UserCredentials.fetch();

    if (userCredentials == null || userCredentials.isExpired) {
      // if user not logged in, tell user to log in
      logger.severe(
        userCredentials == null
            ? 'You are not logged in to Pritt'
            : 'Your login session has expired',
      );
      logger.severe('To log in, run: ${styleBold.wrap('pritt login')}');
      exit(1);
    }

    // establish client
    final client = PrittClient(
      url: userCredentials.uri.toString(),
      accessToken: userCredentials.accessToken,
    );

    // get archive of package
    logger.info('Fetching Adapter $name');

    final content = await client.getAdapterArchiveWithName(name: name);

    final contentLength = content.length;

    // download contents
    final ProgressBar progressBar = ProgressBar(
      'Downloading Adapter',
      completeMessage: 'Adapter Downloaded',
    );

    final outName = (argResults?['output'] ?? name);
    final directory = Directory(outName);

    if (await directory.exists() && !argResults?['force']) {
      logger.severe('Directory already exists.');
      logger.stderr('To overwrite contents, pass the --force flag');
      exit(2);
    } else {
      await directory.create(recursive: true);
    }

    final File tarFile = await File(outName + '.tar.gz').create();
    final sink = tarFile.openWrite();

    int bytesReceived = 0;

    final downloadCompleter = Completer<void>();

    content.data.listen(
      (chunk) {
        sink.add(chunk);
        bytesReceived += chunk.length;
        progressBar.tick(bytesReceived, contentLength);
      },
      onDone: () async {
        await sink.close();
        progressBar.end();
        downloadCompleter.complete();
      },
      onError: (e, st) async {
        await sink.close();
        downloadCompleter.completeError(e, st);
      },
      cancelOnError: true,
    );

    await downloadCompleter.future;

    // now deflate, and open

    logger.info('Expanding Contents');

    // extract tar.gz and save to directory
    await safeExtractTarGz(tarGzFile: tarFile, outputDirectory: directory);

    logger.stdout('Adapter $name has been unpacked at $outName');

    return;
  }
}

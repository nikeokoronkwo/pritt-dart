import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:chunked_stream/chunked_stream.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart' as p;

import '../cli/base.dart';
import '../cli/progress_bar.dart';
import '../client.dart';
import '../config/user_config.dart';
import '../pkg_name.dart';

class UnpackCommand extends PrittCommand {
  @override
  String name = "unpack";

  @override
  String description =
      "Get a package locally and make modifications to the package";

  UnpackCommand() {
    argParser
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Overwrite the target directory if it already exists.',
      )
      ..addFlag('vcs', help: 'Unpack via VCS (Clone)', hide: true)
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

    final pkgName = scope != null ? '@$scope/$name}' : name;

    // get archive of package
    logger.info('Fetching Package $pkgName');

    final content =
        await client.getPackageArchiveWithName(name: pkgName, version: version);

    final contentLength = content.length;

    // download contents
    final ProgressBar progressBar = ProgressBar('Downloading Package',
        completeMessage: 'Package Downloaded');

    final outName = (argResults?['output'] ??
        _suitableFileName(name: name, scope: scope, version: version));
    final directory = Directory(outName);

    if (await directory.exists() && !argResults?['force']) {
      logger.severe('Directory already exists.');
      logger.stderr('To overwrite contents, pass the --force flag');
      exit(2);
    } else {
      await directory.create(recursive: true);
    }

    // final File tarFile = await File(outName + '.tar.gz').create();
    // final sink = tarFile.openWrite();
    final controller = StreamController<List<int>>();

    int bytesReceived = 0;

    final downloadCompleter = Completer<void>();

    content.data.listen(
      (chunk) {
        controller.add(chunk);
        bytesReceived += chunk.length;
        progressBar.tick(bytesReceived, contentLength);
        sleep(Duration(milliseconds: 10));
      },
      onDone: () async {
        await controller.close();
        sleep(Duration(milliseconds: 100));
        progressBar.end();
        downloadCompleter.complete();
      },
      onError: (e, st) async {
        await controller.close();
        sleep(Duration(milliseconds: 100));
        downloadCompleter.completeError(e, st);
      },
      cancelOnError: true,
    );

    await downloadCompleter.future;

    // now deflate, and open

    logger.info('Expanding Contents');

    // extract tar.gz and save to directory
    // await safeExtractTarGz(tarGzFile: tarFile, outputDirectory: directory);
    final Archive archive = TarDecoder().decodeBytes(
        GZipDecoder().decodeBytes(await readByteStream(controller.stream)));

    await extractArchiveToDisk(archive, directory.path);

    await controller.close();

    logger.stdout('Package $pkgName has been unpacked at $outName');

    return;
  }
}

String _suitableFileName(
    {required String name, String? scope, String? version, String? outputDir}) {
  final directoryContext = Directory(
      p.dirname(outputDir == null ? p.current : p.absolute(outputDir)));
  final files = directoryContext.listSync();

  if (scope == null) {
    if (files
        .where((f) => p.basenameWithoutExtension(f.path) == name)
        .isNotEmpty) {
      // if a file has the name
      return '$name@$version';
    } else {
      return name;
    }
  } else {
    if (files
        .where((f) => p.basenameWithoutExtension(f.path) == '@${scope}_$name')
        .isNotEmpty) {
      // if a file has the name
      return '@${scope}_$name@$version';
    } else {
      return '@${scope}_$name';
    }
  }
}

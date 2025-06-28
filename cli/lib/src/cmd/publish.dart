import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:chunked_stream/chunked_stream.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:pritt_common/functions.dart';
import 'package:pritt_common/interface.dart' as common;

import '../adapters/base.dart';
import '../adapters/base/config.dart';
import '../cli/base.dart';
import '../cli/progress_bar.dart';
import '../client.dart';
import '../client/base.dart';
import '../config/user_config.dart';
import '../constants.dart';
import '../login.dart';
import '../utils/extensions.dart';
import '../workspace/vcs.dart';
import '../workspace/workspace.dart';

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
      ..addOption('language',
          abbr: 'l',
          help:
              'If project contains multiple languages, this specifies the primary language to publish/select handlers for.');
  }

  // TODO(nikeokoronkwo): Key Signing Pipeline from User, https://github.com/nikeokoronkwo/pritt-dart/issues/58
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

    var client = PrittClient(url: url);

    // check if user is logged in
    var userCredentials = await UserCredentials.fetch();

    if (userCredentials == null || userCredentials.isExpired) {
      logger.stdout('Logging user in...');
      // if user not logged in, log him in
      userCredentials = await loginUser(client, clientUrl, logger);
      await userCredentials.update();
    }

    // close login client - we need auth for next steps
    client.close();

    // set up new client client
    client = PrittClient(
        url: userCredentials.uri.toString(),
        accessToken: userCredentials.accessToken);

    // 0. PROJECT SETUP
    logger.info('Going through project...');
    var project = await getProject(p.current,
        config: argResults?['config'], client: client);

    // check for a handler to use
    if (project.handlers.isEmpty) {
      logger.severe('Could not find a suitable handler for the given project.');
      logger.stderr(
          'Try installing a handler for the project type from the marketplace, or filing an issue to add support/fix this (if you think it is a bug)');
      exit(1);
    } else {
      // get an active handler
      if (argResults?.wasParsed('language') ?? false) {
        // check for handler for language
        try {
          final langHandler = project.handlers
              .firstWhere((l) => l.language == argResults!['language']);
          project.primaryHandler = langHandler;
        } on StateError catch (e) {
          logger.severe(
              'Could not find any adapters matching the given language ${argResults!['language']}');
          logger.verbose(e.message);
          exit(1);
        }
      } else {
        // check if single
        try {
          project.primaryHandler = project.handlers.single;
        } on StateError catch (e) {
          logger.severe(
              'Found more than one handler matching the given project.');
          for (var h in project.handlers) {
            logger.stderr('\t- ${h.language}');
          }
          logger.stderr(
              'You will need to pick one by rerunning this with the "--language" flag');
          logger.verbose(e.message);
          throw UsageException('', usage);
        }
      }
    }

    // 1. get information about current package information
    logger.info('Getting Package Configuration...');
    // get package config
    final handlerWorkspace = await project.getWorkspace();
    final config = handlerWorkspace.config;

    final configContents = await project.getConfig();

    // get package metadata
    final metadata = await project.getEnv();

    // assemble data
    final (name, scope: scope) = parsePackageName(config.name);
    final version = config.version;

    // 2. PUBLISH
    // first of all, check if package exists
    common.GetPackageResponse? basePackage;

    try {
      final pkg = await (scope == null
          ? client.getPackageByName(name: name)
          : client.getPackageByNameWithScope(scope: scope, name: name));

      basePackage = pkg;

      await (scope == null
          ? client.getPackageByNameWithVersion(name: name, version: version)
          : client.getPackageByNameWithScopeAndVersion(
              scope: scope, name: name, version: version));

      logger.stderr(
          'Error: The package ${config.name} with version $version already exists.');
      exit(1);
    } catch (e) {
      // continue
    }

    logger.info('Beginning Publishing...');

    // now the publishing routine
    if (project.primaryHandler.publisher == PublishManager.pm) {
      // TODO(nikeokoronkwo): Implement Package Manager Publishing, https://github.com/nikeokoronkwo/pritt-dart/issues/55
      logger.stderr('ERROR: Package Manager Publishing is not yet implemented');

      return;
    }

    String? uploadUrl;
    String pubId;

    // send publish initiate request to endpoint
    try {
      if (basePackage == null) {
        // create package with version
        final pkgRequest = assemblePubRequest(
          name: name,
          scope: scope,
          config: config,
          configContents: configContents,
          configFile: project.primaryHandler.configFile,
          language: project.primaryHandler.language,
          env: metadata,
          vcs: project.vcs != common.VCS.other ? project.vcs : null,
          vcsUrl: project.vcs != common.VCS.other
              ? await getVcsRemoteUrl(project.vcs)
              : null,
        );

        final pubInitResponse = await (scope == null
            ? client.publishPackage(pkgRequest, name: name)
            : client.publishPackageWithScope(pkgRequest,
                scope: scope, name: name));

        uploadUrl = pubInitResponse.url;
        pubId = pubInitResponse.queue.id;
      } else {
        // create new package, with new version
        final pkgRequest = assemblePubVerRequest(
          name: name,
          scope: scope,
          config: config,
          configContents: configContents,
          configFile: project.primaryHandler.configFile,
          language: project.primaryHandler.language,
          env: metadata,
        );

        final pubInitResponse = await (scope == null
            ? client.publishPackageVersion(pkgRequest,
                name: name, version: version)
            : client.publishPackageWithScopeAndVersion(pkgRequest,
                scope: scope, name: name, version: version));

        uploadUrl = pubInitResponse.url;
        pubId = pubInitResponse.queue.id;
      }
    } on ApiException catch (e) {
      logger.describe(e);
      exit(1);
    } catch (e, _) {
      logger
          .stdout('An unknown error occured while initiating publishing task');
      logger.verbose(e);
      exit(2);
    }

    // given url and stuff, lets zip up and upload
    logger.info('Zipping Up Package...');
    final archive = await createArchiveFromDirectory(project.files(),
        rootDir: project.directory);
    final tarball = GZipEncoder().encode(TarEncoder().encode(archive))!;
    logger.fine('Completed Zipping Package!');

    final ProgressBar progressBar =
        ProgressBar('Uploading Package', completeMessage: 'Package Uploaded');

    int contentLength = tarball.length;
    int bytesUploaded = 0;

    final uploadCompleter = Completer<void>();

    final Stream<Uint8List> tarballStream = asChunkedStream(
            16, Stream.fromIterable(tarball))
        .asBroadcastStream()
        .transform(StreamTransformer.fromHandlers(handleData: (chunk, sink) {
          sink.add(Uint8List.fromList(chunk));
          bytesUploaded += chunk.length;
          progressBar.tick(bytesUploaded, contentLength);
          sleep(Duration(milliseconds: 10));
        }, handleDone: (sink) async {
          sink.close();
          sleep(Duration(milliseconds: 100));
          progressBar.end();
          uploadCompleter.complete();
        }, handleError: (e, st, sink) {
          sink.close();
          uploadCompleter.completeError(e, st);
        }));

    // receive and write endpoint pub request
    // upload
    if (uploadUrl != null) {
      // PUT
      final request = StreamedRequest('PUT', Uri.parse(uploadUrl));
      request.headers[HttpHeaders.contentTypeHeader] = 'application/gzip';
      request.headers[HttpHeaders.authorizationHeader] =
          'Bearer ${userCredentials.accessToken}';
      request.contentLength = contentLength;
      await for (final chunk in ByteStream.fromBytes(tarball)) {
        request.sink.add(chunk);
      }
      await request.sink.close();
      final response = await client.client.send(request);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        logger.severe('Failed to upload package: ${response.statusCode}');
        exit(1);
      }
      // await uploadCompleter.future;
    } else {
      try {
        final _ = await client.uploadPackageWithToken(
            common.StreamedContent(
                archivePath(name, version: version, scope: scope),
                tarballStream,
                contentLength),
            id: pubId);
      } on ApiException catch (e) {
        logger.describe(e);
        exit(1);
      }
    }

    // while endpoint is being listened to: wait
    logger.stdout('Waiting for publishing to finish...');
    await waitForPublishingQueueToComplete(client, pubId);

    // complete pub
    logger.fine(
        'Completed publishing package: ${scopedName(name, scope)}@$version');
    return;
  }

  Future waitForPublishingQueueToComplete(PrittClient client, String pubID,
      {Duration? pollInterval}) async {
    common.PublishPackageStatusResponse response;
    try {
      response = await client.getPackagePubStatus(id: pubID);
      _clearAndWrite('Publishing Status: ${response.status.value}');
    } on ApiException catch (e) {
      logger.describe(e);
      exit(1);
    }
    while (response.status != common.PublishingStatus.success &&
        response.status != common.PublishingStatus.error) {
      await Future.delayed(pollInterval ?? Duration(milliseconds: 600),
          () async {
        response = await client.getPackagePubStatus(id: pubID);
        _clearAndWrite('Publishing Status: ${response.status.value}');
      });
    }

    switch (response.status) {
      case common.PublishingStatus.success:
        print('\n');
        // pub complete
        return;
      default:
        // error
        logger.severe('Oh no! The package publishing process did not succeed');
        logger.severe('Error: ${response.error ?? 'unknown error occurred'}');
        logger.verbose(response.description ?? 'no description');
        exit(1);
    }
  }
}

void _clearAndWrite(String text) {
  stdout.write('\r\x1B[2K$text');
}

common.PublishPackageRequest assemblePubRequest({
  required String name,
  String? scope,
  required Config config,
  required String configContents,
  required String configFile,
  required String language,
  Map<String, dynamic>? env,
  common.VCS? vcs,
  String? vcsUrl,
  String? readme,
  String? readmeFormat,
}) {
  assert(
      vcsUrl == null || vcs != null, "If VCS Url is set, then VCS must be set");
  return common.PublishPackageRequest(
      name: name,
      scope: scope,
      version: config.version,
      language: language,
      config: common.Configuration(path: configFile, config: config.rawConfig),
      env: env,
      info: config.configMetadata,
      vcs: vcs != null
          ? common.VersionControlSystem(name: vcs, url: vcsUrl)
          : null);
}

common.PublishPackageByVersionRequest assemblePubVerRequest({
  required String name,
  String? scope,
  required Config config,
  required String configContents,
  required String configFile,
  required String language,
  Map<String, dynamic>? env,
  String? readme,
  String? readmeFormat,
}) {
  return common.PublishPackageByVersionRequest(
      name: name,
      scope: scope,
      version: config.version,
      language: language,
      config: common.Configuration(path: configFile, config: config.rawConfig),
      env: env,
      info: config.configMetadata);
}

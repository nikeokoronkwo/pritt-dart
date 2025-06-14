import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:pritt_common/functions.dart';
import 'package:pritt_common/interface.dart' as common;

import '../adapters/base.dart';
import '../adapters/base/config.dart';
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
      ..addOption('language',
          abbr: 'l',
          help:
              'If project contains multiple languages, this specifies the primary language to publish/select handlers for.');
  }

  // TODO: Key Signing from User
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
      logger.stdout('Logging user in...');
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

    // 0. PROJECT SETUP
    logger.info('Going through project...');
    var project = await getWorkspace(p.current,
        config: argResults?['config'], client: prittClient);

    // check for a handler to use
    if (project.handlers.isEmpty) {
      logger.severe('Could not find a suitable handler for the given project.');
      // TODO: Links to go to
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

    // get README, if available
    final (readme, format: readmeFormat) = project.readme;

    // get CHANGELOG, if available

    // get LICENSE info, if possible

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

      final pkgVersion = await (scope == null
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
      // TODO: Implement Package Manager Publishing
      logger.stderr('ERROR: Package Manager Publishing is not yet implemented');

      return;
    }

    // send publish initiate request to endpoint
    if (basePackage != null) {
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
          readme: readme,
          readmeFormat: readmeFormat);

      final pubInitResponse = await (scope == null
          ? client.publishPackage(pkgRequest, name: name)
          : client.publishPackageWithScope(pkgRequest,
              scope: scope, name: name));
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
          readme: readme,
          readmeFormat: readmeFormat);

      final pubInitResponse = await (scope == null
          ? client.publishPackageVersion(pkgRequest,
              name: name, version: version)
          : client.publishPackageWithScopeAndVersion(pkgRequest,
              scope: scope, name: name, version: version));
    }

    // receive and write endpoint pub request

    // while endpoint is being listened to: wait

    // receive package id and other stuff

    // validate that user wants to publish package

    // once completed auth,

    // zip package

    // publish user package with id
  }

  Future<String?> getVcsRemoteUrl(common.VCS vcs, {String? directory}) async {
    Future<String?> getvcsurl(executable, args) async {
      final process = await rootRunner.manager
          .spawn(executable, args, workingDirectory: directory ?? p.current);

      final stdout = await process.stdout.transform(utf8.decoder).join();
      final stderr = await process.stderr.transform(utf8.decoder).join();
      final exitCode = await process.exitCode;

      if (exitCode == 0) {
        return stdout.trim();
      } else {
        logger.warn('Could not get $executable remote url');
        logger.verbose('STDOUT: $stdout');
        logger.verbose('STDERR: $stderr');
        return null;
      }
    }

    return switch (vcs) {
      common.VCS.git =>
        await getvcsurl('git', ['config', '--get', 'remote.origin.url']),
      common.VCS.svn => await getvcsurl('svn', ['info', '--show-item', 'url']),
      common.VCS.fossil => await getvcsurl('fossil', ['remote-url']) ??
          await getvcsurl('fossil', ['info']).then((out) {
            final match = RegExp(r'url:\s*(.*)').firstMatch(out ?? '');
            return match?.group(1);
          }),
      common.VCS.mercurial => await getvcsurl('hg', ['paths', 'default']),
      _ => null
    };
  }
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
      config: common.Configuration(
          path: configFile, config: config.rawConfig, contents: configContents),
      env: env,
      info: config.configMetadata,
      vcs: vcs != null
          ? common.VersionControlSystem(name: vcs, url: vcsUrl)
          : null,
      readme: readme != null
          ? common.Readme(
              name: 'README${'.${readmeFormat ?? ''}'}',
              format: readmeFormat ?? 'md',
              contents: readme)
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
      config: common.Configuration(
          path: configFile, config: config.rawConfig, contents: configContents),
      env: env,
      info: config.configMetadata,
      readme: readme != null
          ? common.Readme(
              name: 'README${'.${readmeFormat ?? ''}'}',
              format: readmeFormat ?? 'md',
              contents: readme)
          : null);
}

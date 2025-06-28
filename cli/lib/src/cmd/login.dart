import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../cli/base.dart';
import '../client.dart';
import '../client/base.dart';
import '../config/user_config.dart';
import '../constants.dart';
import '../login.dart';
import '../utils/extensions.dart';

class LoginCommand extends PrittCommand {
  @override
  String name = "login";

  @override
  String description = "Login to the Pritt Server";

  @override
  List<String> get aliases => ['signin'];

  LoginCommand() {
    argParser
      ..addOption('url',
          abbr: 'u',
          help:
              "The URL of the pritt server. Defaults to the main pritt instance (you can also just pass 'main' to indicate the main server).\n"
              "By default, if this is not a local instance of pritt, or 'main', an 'api' prefix will be placed in front of this URL\nif not specified already, and omitted for the Client URL.\n"
              "To prevent this default behaviour, you can specify the client URL using the '--client-url' option.",
          valueHelp: 'url')
      ..addFlag('new',
          negatable: false,
          defaultsTo: false,
          help:
              'Forces logging into Pritt even if already logged into the current client. (useful for logging into a different account)')
      ..addOption('client-url',
          valueHelp: 'url',
          help:
              "The URL of the pritt client. Defaults to the main pritt instance (you can also just pass 'main' to indicate the main server).\nUse this only when you need to specify a separate URL for the client, like when using on a local instance.",
          aliases: ['client']);
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
      if (url == mainPrittApiUrl.toString()) {
        clientUrl = mainPrittInstance;
      } else {
        clientUrl = url;
        final uri = Uri.parse(url);
        url = uri.replace(host: 'api.${uri.host}').toString();
      }
    }

    final client = PrittClient(url: url);

    try {
      // check if user is logged in
      var userCredentials = await UserCredentials.fetch();

      if (userCredentials == null ||
          userCredentials.isExpired ||
          userCredentials.uri.toString() != url ||
          argResults?['new']) {
        // else log user in
        userCredentials = await loginUser(client, clientUrl, logger);
        await userCredentials.update();
      } else {
        // if user is logged in, and token is not expired, display user info
        logger.info("You are already logged in...");
      }

      // get user info from login details
      final user = await client.getUserById(id: userCredentials.userId);
      // TODO(nikeokoronkwo): Cache user, https://github.com/nikeokoronkwo/pritt-dart/issues/31

      // display user log in info
      logger.fine('Logged in as: ${user.name}');
      if (user.name == '') {
        logger.warn(
            'Warning: Your name seems to be empty. Try logging into ${clientUrl == mainPrittInstance ? 'Pritt' : 'your Pritt instance'} on the web and update your name');
      }

      exit(0);
    } on ApiException catch (e) {
      logger.describe(e);
      exit(1);
    } on Exception catch (e) {
      logger.severe('Error: $e');
      exit(1);
    }
  }
}

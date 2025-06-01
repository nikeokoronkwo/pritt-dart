import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:pritt_cli/src/client.dart';
import 'package:pritt_cli/src/constants.dart';
import 'package:pritt_cli/src/device_id.dart';
import 'package:pritt_cli/src/user_config.dart';
import 'package:pritt_cli/src/utils/extensions.dart';
import 'package:pritt_common/interface.dart';

import '../cli/base.dart';

class LoginCommand extends PrittCommand {
  @override
  String name = "login";

  @override
  String description = "Login to the Pritt Server";

  LoginCommand() {
    argParser
      ..addOption('url',
          abbr: 'u',
          help:
              "The URL of the pritt server. Defaults to the main pritt instance (you can also just pass 'main' to indicate the main server)",
          valueHelp: 'url')
      ..addFlag('headless',
          negatable: false,
          defaultsTo: false,
          help: 'Run login on the CLI. Defaults to false (launch browser)');
  }

  @override
  FutureOr? run() async {
    // get arguments
    String? url = argResults!['url'];

    // validate arguments
    if (url != null) {
      if (url == 'main') {
        url = mainPrittInstance;
      } else if (!url.isUrl) {
        throw UsageException("'url' option must be valid URL", usage);
      }
    } else {
      url = mainPrittInstance;
    }

    final client = PrittClient(url: url);

    // check if user is logged in
    var userCredentials = await UserCredentials.fetch();

    if (userCredentials == null || userCredentials.isExpired) {
      // else log user in
      userCredentials = await _loginUser(client);
      await userCredentials.update();
    } else {
      // if user is logged in, and token is not expired, display user info
      logger.info("You are already logged in...");
    }

    // get user info from login details

    // display user log in info
  }

  /// Log a user in to the Pritt server
  Future<UserCredentials> _loginUser(PrittClient client,
      {UserCredentials? credentials}) async {
    // get device ID
    final deviceId = await getDeviceId();

    // request for an auth
    final authRequest = await client.createNewAuthStatus(id: deviceId);

    final expiresDate = DateTime.parse(authRequest.token_expires);

    // present auth request
    logger.stdout(
        'You can complete logging in using this URL: ${Uri.parse(client.url).replace(path: 'auth', queryParameters: {
          'id': authRequest.token
        })}');
    logger.info(
        'NOTE: This token expires at ${expiresDate.hour.toString().padLeft(2, '0')}:${expiresDate.minute.toString().padLeft(2, '0')}');

    var authPollStatus = PollStatus.pending;
    var authPollResponse;

    while (authPollStatus == PollStatus.pending) {
      final authStatus = await client.getAuthStatus(id: authRequest.token);

      switch (authStatus.status) {
        case PollStatus.fail:
        case PollStatus.error:
          authPollResponse = authStatus.response;
          authPollStatus = authStatus.status;
          break;
        default:
          authPollStatus = authStatus.status;
          break;
      }

      // sleep for a while
      sleep(Duration(milliseconds: 1500));
    }

    // check the status
    switch (authPollStatus) {
      case PollStatus.success:
        // TODO: Handle this case.
        throw UnimplementedError();
      case PollStatus.fail:
        // TODO: Handle this case.
        throw UnimplementedError();
      case PollStatus.error:
        // TODO: Handle this case.
        throw UnimplementedError();
      case PollStatus.expired:
        // TODO: Handle this case.
        throw UnimplementedError();
      case PollStatus.pending:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    throw UnimplementedError('Login not implemented yet');
  }
}

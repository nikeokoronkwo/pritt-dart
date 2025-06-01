import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:args/command_runner.dart';
import 'package:http/http.dart';
import 'package:pritt_cli/src/client.dart';
import 'package:pritt_cli/src/client/base.dart';
import 'package:pritt_cli/src/constants.dart';
import 'package:pritt_cli/src/device_id.dart';
import 'package:pritt_cli/src/user_config.dart';
import 'package:pritt_cli/src/utils/extensions.dart';
import 'package:pritt_cli/src/utils/log.dart';
import 'package:pritt_common/interface.dart';

import '../cli/base.dart';

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
      clientUrl = mainPrittInstance;
    }

    final client = PrittClient(url: url);

    try {
      // check if user is logged in
      var userCredentials = await UserCredentials.fetch();

      if (userCredentials == null || userCredentials.isExpired) {
        // else log user in
        userCredentials = await _loginUser(client, clientUrl);
        await userCredentials.update();
      } else {
        // if user is logged in, and token is not expired, display user info
        logger.info("You are already logged in...");
      }

      // get user info from login details
      final user = await client.getUserById(id: userCredentials.userId);
      // TODO: Cache user

      // display user log in info
      logger.fine('Logged in as: ${user.name}');
    } on ApiException catch (e) {
      logger.describe(e);
      exit(1);
    } on SocketException catch (e) {
    } on ClientException catch (e) {
    } on Exception catch (e) {
      logger.severe('Error: $e');
      exit(1);
    }
  }

  /// Log a user in to the Pritt server
  Future<UserCredentials> _loginUser(PrittClient client, String clientUrl,
      {UserCredentials? credentials}) async {
    // check the client is real
    if (!(await client.healthCheck())) {
      throw Exception(
          'The client did not pass healthcheck: confirm this client exists');
    }

    // get device ID
    final deviceId = await getDeviceId();

    // request for an auth
    final authRequest = await client.createNewAuthStatus(id: deviceId);

    final expiresDate = DateTime.parse(authRequest.token_expires);

    // present auth request
    logger.stdout(
        'You can complete logging in using this URL: ${Uri.parse(clientUrl).replace(path: 'auth', queryParameters: {
          'id': authRequest.token
        })}');
    logger.info(
        'NOTE: This token expires at ${_getTime(expiresDate.toLocal(), verbose: logger is VerboseLogger)} (${(expiresDate.isUtc ? expiresDate : expiresDate.toUtc()).hour.toString().padLeft(2, '0')}:${(expiresDate.isUtc ? expiresDate : expiresDate.toUtc()).minute.toString().padLeft(2, '0')} UTC)');

    var authPollStatus = PollStatus.pending;
    Map<String, dynamic> authPollResponse = {};

    logger.stdout('Waiting for response...');

    while (authPollStatus == PollStatus.pending) {
      final authStatus = await client.getAuthStatus(id: authRequest.token);

      switch (authStatus.status) {
        case PollStatus.fail:
        case PollStatus.error:
          authPollResponse = authStatus.response ?? {};
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
        // log success
        logger.fine('You are successfully logged in!');
        String id;
        if (authPollResponse['id'] != null) {
          id = authPollResponse['id'];
        } else {
          final details =
              await client.getAuthDetailsById(id: authRequest.token);
          id = details.user_id ??
              'unknown'; // TODO: Exception, rather than 'unknown'
        }

        return await UserCredentials.create(
            authPollResponse['access_token'] as String,
            id: id,
            uri: Uri.parse(client.url),
            accessTokenDuration: (authPollResponse['access_token_expires_at']
                        is String
                    ? DateTime.parse(
                        authPollResponse['access_token_expires_at'])
                    : authPollResponse['access_token_expires_at'] as DateTime)
                .difference(DateTime.now())
                .inSeconds);
      case PollStatus.fail:
        // TODO: Handle this case.
        throw Exception('Login Failed');
      case PollStatus.error:
        // TODO: Handle this case.
        throw Exception('Error Occured During Login: $authPollResponse');
      case PollStatus.expired:
        // TODO: Handle this case.
        throw ExpiredError(
            expired_time: authPollResponse['access_token_expires_at']);
      case PollStatus.pending:
        // TODO: Handle this case.
        throw Exception();
    }
  }
}

String _getTime(DateTime time, {bool verbose = true}) {
  if (verbose) return time.toIso8601String();
  
  int hour = time.hour;
  int mins = time.minute;
  String suffix = time.hour >= 12 ? 'pm' : 'am';
  
  return '${hour > 12 ? hour - 12 : hour}:${mins.toString().padLeft(2, '0')}';
}
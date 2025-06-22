import 'dart:io';

import 'package:io/ansi.dart';
import 'package:pritt_common/interface.dart';

import 'client.dart';
import 'device_id.dart';
import 'user_config.dart';
import 'utils/log.dart';

/// Log a user in to the Pritt server
Future<UserCredentials> loginUser(
    PrittClient client, String clientUrl, Logger logger) async {
  // check the client is real
  if (!(await client.healthCheck())) {
    throw Exception(
        'The client did not pass healthcheck: does the client exist?');
  }

  // get device ID
  final deviceId = await getDeviceId();

  // request for an auth
  final authRequest = await client.createNewAuthStatus(id: deviceId);

  final expiresDate = DateTime.parse(authRequest.token_expires);

  // present auth request
  logger.fine('Login Attempt!');
  logger.stdout(
      'You can complete logging in using this URL: ${styleUnderlined.wrap(Uri.parse(clientUrl).replace(path: 'auth', queryParameters: {
        'id': authRequest.token
      }).toString())}');
  logger.stdout(
      'Enter the given code: ${wrapWith(authRequest.code, [styleBold])}');
  logger.info(
      'NOTE: This token expires at ${_getTime(expiresDate.toLocal(), verbose: logger is VerboseLogger)} (${(expiresDate.isUtc ? expiresDate : expiresDate.toUtc()).hour.toString().padLeft(2, '0')}:${(expiresDate.isUtc ? expiresDate : expiresDate.toUtc()).minute.toString().padLeft(2, '0')} UTC)');

  var authPollStatus = PollStatus.pending;
  Map<String, dynamic> authPollResponse = {};

  logger.stdout('Waiting for response...');

  while (authPollStatus == PollStatus.pending) {
    final authStatus = await client.getAuthStatus(id: authRequest.token);

    authPollStatus = authStatus.status;
    authPollResponse = authStatus.response ?? {};

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
        final details = await client.getAuthDetailsById(id: authRequest.token);
        id = details.user_id ??
            'unknown'; // TODO: Exception, rather than 'unknown'
      }

      return await UserCredentials.create(
          authPollResponse['access_token'] as String,
          id: id,
          uri: Uri.parse(client.url),
          accessTokenDuration: (authPollResponse['access_token_expires_at']
                      is String
                  ? DateTime.parse(authPollResponse['access_token_expires_at'])
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

String _getTime(DateTime time, {bool verbose = true}) {
  if (verbose) return time.toIso8601String();

  int hour = time.hour;
  int mins = time.minute;
  String suffix = time.hour >= 12 ? 'pm' : 'am';

  return '${hour > 12 ? hour - 12 : hour}:${mins.toString().padLeft(2, '0')} $suffix';
}

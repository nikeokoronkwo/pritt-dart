import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:io/ansi.dart';
import 'package:pritt_cli/src/client.dart';
import 'package:pritt_cli/src/user_config.dart';

import '../cli/base.dart';

class InfoCommand extends PrittCommand {
  @override
  String name = "info";

  @override
  String description =
      "Get current information about the currently logged in user";

  @override
  void run() async {
    // check if user is logged in
    var userCredentials = await UserCredentials.fetch();

    if (userCredentials == null || userCredentials.isExpired) {
      // if user not logged in, tell user to log in
      logger.severe(userCredentials == null ? 'You are not logged in to Pritt' : 'Your login session has expired');
      logger.severe('To log in, run: ${styleBold.wrap('pritt login')}');
      exit(1);
    }

    // if user is logged in, get user info
    final client = PrittClient(url: userCredentials.uri.toString(), accessToken: userCredentials.accessToken);
    final user = await client.getCurrentUser();

    // print user info as table
    logger.fine('User Information For: ${styleDim.wrap('${user.name} <${user.email}>')}');
    final userAsJson = user.toJson();

    userAsJson.entries.map((e) {
      logger.stdout('\t${styleBold.wrap(e.key)}: ${e.key.endsWith('_at') ? transformDate(e.value) : e.value}');
    });
  }
}

String transformDate(String dateString) {
  final date = DateTime.parse(dateString).toLocal();
  return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year} at ${date.hour}:${date.minute}';
}

String transformKey(String key) {
  if (key == 'updated_at') return 'Last Updated At';
  return key.splitMapJoin('_', onMatch: (_) => ' ', onNonMatch: (v) {
    var out = v.split('');
    out[0] = out[0].toUpperCase();
    return out.join();
  });
}
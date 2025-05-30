import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:io/ansi.dart';
import 'package:pritt_cli/src/cli/base.dart';
import 'package:pritt_cli/src/client.dart';
import 'package:pritt_cli/src/constants.dart';
import 'package:pritt_cli/src/csv.dart';
import 'package:pritt_cli/src/list.dart';
import 'package:pritt_cli/src/output.dart';
import 'package:pritt_cli/src/user_config.dart';

class AdapterListCommand extends PrittCommand {
  @override
  String name = "list";

  @override
  // TODO: implement description
  String get description =>
      "List all the adapters at the current pritt endpoint";

  AdapterListCommand() {
    argParser
      ..addOption('json',
          help: 'Write as a JSON output to a file', valueHelp: 'file')
      ..addOption('csv',
          help: 'Write as CSV output to a file', valueHelp: 'file');
  }

  @override
  void run() async {
    try {
      // check if user is logged in
      var userCredentials = await UserCredentials.fetch();

      if (userCredentials == null || userCredentials.isExpired) {
        // else log user in
        logger.severe(userCredentials == null
            ? 'You are not logged in to Pritt'
            : 'Your login session has expired');
        logger.severe('To log in, run: ${styleBold.wrap('pritt login')}');
        exit(1);
      }

      // set up pritt client
      var client = PrittClient(
          url: userCredentials.uri.toString(),
          accessToken: userCredentials.accessToken);

      // get packages
      var pkgs = await client.getAdapters();

      if (pkgs.adapters == null || (pkgs.adapters ?? []).isEmpty) {
        logger.stdout('There are no adapters');
        logger.stdout(
            'You can check for adapters at the Pritt Plugin Hub: ${mainPrittUrl.replace(path: '/plugins')}');
        return;
      }

      // get output format
      var format = argResults != null
          ? getFormatFromResults(argResults!)
          : OutputFormat.text;

      switch (format) {
        case OutputFormat.text:
          listAdapterInfo(pkgs.adapters!);
        case OutputFormat.csv:
          final jsonOutput = pkgs.adapters!.map((p) => p.toJson());
          await File(argResults?['csv'] ?? 'results.csv')
              .writeAsString(csvEncode(jsonOutput));
        case OutputFormat.json:
          final jsonOutput = pkgs.adapters!.map((p) => p.toJson());
          await File(argResults?['json'] ?? 'results.json')
              .writeAsString(jsonEncode(jsonOutput));
      }
    } on ClientException catch (e) {
      logger.severe(
          'Failed to connect to Pritt Instance at ${e.uri?.removeFragment().replace(
                path: '',
                query: '',
              ) ?? styleItalic.wrap('unknown')}');
      if (e.message.startsWith('Failed host lookup'))
        logger.severe(
            'Either the URL does not exist, or you are not connected to the internet');
      exit(1);
    }
  }
}

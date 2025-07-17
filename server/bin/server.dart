import 'dart:io';

import 'package:args/args.dart';
import 'package:http_multi_server/http_multi_server.dart';
import 'package:pritt_server/adapter_handler.dart';
import 'package:pritt_server/pritt_server.dart';
import 'package:pritt_server/server_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

// TODO(nikeokoronkwo): Support file logging and external logging, https://github.com/nikeokoronkwo/pritt-dart/issues/49
final _argParser = ArgParser()
  ..addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Show this help message.',
  )
  ..addFlag(
    'custom-adapters',
    negatable: true,
    defaultsTo: true,
    help:
        'Enable or disable custom adapters. If disabled, only the default adapters will be used.',
  )
  ..addMultiOption(
    'experimental',
    abbr: 'e',
    allowed: ExperimentalFeature.values.map((v) => v.name),
    defaultsTo: [],
    help: 'Enable experimental features',
    allowedHelp: ExperimentalFeature.values.asMap().map(
      (_, feature) => MapEntry(feature.name, feature.description),
    ),
  );

enum ExperimentalFeature {
  dualEndpoint(
    'dual_endpoint',
    'Enable dual endpoint support for the Pritt server: \nRuns the main and adapter handlers as separate endpoints.',
  );

  const ExperimentalFeature(this.name, this.description);
  final String name;
  final String description;

  static ExperimentalFeature fromString(String value) {
    return ExperimentalFeature.values.firstWhere(
      (feature) => feature.name == value,
      orElse: () => throw ArgumentError('Unknown experimental feature: $value'),
    );
  }
}

void main(List<String> args) async {
  // ============ ARGUMENT PARSING ============
  final argResults = _argParser.parse(args);

  if (argResults.wasParsed('help')) {
    print('Usage: dart server/bin/server.dart [options]');
    print(_argParser.usage);
    exit(0);
  }

  final experimentalFeatures = (argResults['experimental'] as List<String>).map(
    ExperimentalFeature.fromString,
  );

  // ============ END ARGUMENT PARSING ============

  // PRE SETUP
  final enableCustomAdapters =
      argResults['custom-adapters'] ??
      int.tryParse(
            Platform.environment['PRITT_IGNORE_CUSTOM_ADAPTERS'] ?? '0',
          ) !=
          1;

  await startPrittServices(customAdapters: enableCustomAdapters);

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  if (experimentalFeatures.contains(ExperimentalFeature.dualEndpoint)) {
    // implement dual endpoint support
    final adapterApplication = adapterHandler(crs);
    final apiApplication = Cascade()
        .add(preFlightHandler())
        .add(serverHandler());

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(adapterApplication);

    final apiHandler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(apiApplication.handler);

    // For running in containers, we respect the PORT environment variable.
    final apiPort = int.parse(
      Platform.environment['PORT'] ??
          Platform.environment['API_PORT'] ??
          '8080',
    );
    final adapterPort = int.parse(
      Platform.environment['REGISTRY_PORT'] ?? '8081',
    );

    final _ = HttpMultiServer([
      await io.serve(handler, ip, adapterPort),
      await io.serve(apiHandler, ip, apiPort),
    ]);

    print('Adapter server listening on port $adapterPort');
    print('API server listening on port $apiPort');
  } else {
    // implement single endpoint support
    // TODO: Make single endpoint concurrent
    // SERVER SETUP
    final app = createRouter();

    // Configure a pipeline that logs requests.
    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(app);

    // For running in containers, we respect the PORT environment variable.
    final port = int.parse(Platform.environment['PORT'] ?? '8080');

    final server = await io.serve(handler, ip, port);
    print('Server listening on port ${server.port}');
  }
}

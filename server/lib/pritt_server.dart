import 'dart:io';

import 'package:pritt_adapter/pritt_adapter.dart';
import 'package:pritt_api/pritt_api.dart';
import 'package:pritt_server_core/pritt_server_core.dart';
import 'package:shelf/shelf.dart';

import 'adapter_handler.dart';

late final AdapterRegistry registry;

Future<void> startPrittServices({
  String? ofsUrl,
  String? dbUrl,
  bool customAdapters = true
}) async {
  final (:storage, :db) = await startCRSServices(ofsUrl: ofsUrl, dbUrl: dbUrl);

  // TODO: Late Initialization Check
  try {
    final _ = crs;
  } catch (e) {
    crs = await CoreRegistryService.connect(db: db, storage: storage);
  }

  if (customAdapters) {
    registry = await AdapterRegistry.connect(
      db: db,
      runnerUri: Uri.parse(Platform.environment['PRITT_RUNNER_URL']!),
    );
  }

  publishingTaskRunner.start();
}


Handler createRouter() {
  // create router for openapi routes

  // the main handler
  /// TODO: We can improve the performance a bit more:
  /// We have two request handlers here, but we only need one.
  /// Rather than cascading between, we can run the two requests (adapter and preflight+server) in parallel and set priorities
  /// When both finish (the adapter resolver) and the server handler, then the one that is successful gets passed down
  ///
  /// The performance need not be extremely much, so we can (and probably should) use Dart Isolates.
  /// However, I need to find out how to pass [Request] and [Response] objects to and fro
  /// An idea is to implement a [WorkerHandler] object with three functions:
  /// - one to convert the request object into the necessary parameters to the main function
  /// - the main function that is run in the isolate
  /// - one to convert the isolate return to the response object
  ///
  ///
  /// This will be very helpful in DS, where the `vm_isolates` preset may need some message passing,
  /// However, this means that the `Event` object will no longer be standard/based on Shelf [Request]
  final cascade = Cascade()
      .add(adapterHandler(crs))
      .add(preFlightHandler())
      .add(serverHandler());

  return cascade.handler;
}

import 'package:pritt_server/adapter_handler.dart';
import 'package:pritt_server/server_handler.dart';
import 'package:shelf/shelf.dart';

import 'src/main/crs/crs.dart';

late CoreRegistryService crs;

Handler createRouter() {
  // create router for openapi routes

  // the main handler
  final cascade = Cascade().add(adapterHandler(crs)).add(serverHandler());

  return cascade.handler;
}



import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Handler createRouter() {
  // create router for openapi routes
  final app = Router();

  // create handler for adapters
  Handler adapterHandler = (Request req) {
    if (req.url.path == '/') return Response.ok('Server Active');
    return Response.notFound('Not Found');
  };
  
  // the m
  final cascade = Cascade()
  .add(adapterHandler)
  .add(app.call);

  return cascade.handler;
}
import 'package:pritt_server/src/lib/adapter/adapter_base.dart';
import 'package:pritt_server/src/lib/adapter/adapter_registry.dart';
import 'package:pritt_server/src/utils/resolve.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Handler createRouter() {
  // create router for openapi routes
  final app = Router()..get('/', (req) => Response.ok('Hello'));

  // the main handler
  final cascade = Cascade().add(adapterHandler()).add(app.call);

  return cascade.handler;
}

Handler adapterHandler() {
  return (Request req) async {
    try {
      final adapterResolve = getAdapterResolveObject(req);

      // connect to the adapter registry
      final adapterRegistry = await AdapterRegistry.connect();

      // check through the core adapters first
      var adapter = adapterRegistry.findInCore(adapterResolve);
      if (adapter != null) {
        // check through custom
        adapter = await adapterRegistry.find(adapterResolve, checkedCore: true);
      }

      // once we get an adapter, we can then begin the adapter life cycle

      // ...

      // return response
      return Response.ok(Object());
    } on AdapterException catch (_) {
      // could not find adapter
      return Response.notFound('unsupported package manager');
    } on Exception catch (e) {
      return Response.notFound('error: $e');
    }
  };
}

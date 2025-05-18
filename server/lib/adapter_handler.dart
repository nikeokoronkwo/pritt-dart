import 'dart:convert';
import 'package:pritt_server/src/main/adapter/adapter_base.dart';
import 'package:pritt_server/src/main/adapter/adapter_registry.dart';
import 'package:pritt_server/src/main/crs/crs.dart';
import 'package:pritt_server/src/utils/resolve.dart';
import 'package:pritt_server/src/utils/xml.dart';
import 'package:shelf/shelf.dart';

Handler adapterHandler(CoreRegistryService crs) {
  return (Request req) async {
    try {
      final adapterResolve = getAdapterResolveObject(req);

      // connect to the adapter registry
      final adapterRegistry = await AdapterRegistry.connect();

      // check through the core adapters first
      var adapterSearchResult = adapterRegistry.findInCore(adapterResolve);
      adapterSearchResult ??=
          await adapterRegistry.find(adapterResolve, checkedCore: true);

      final adapter = adapterSearchResult.adapter;

      // once we get an adapter, we can then begin the adapter life cycle
      final result = await adapter.run(
          adapter.language == null ? crs : crs.controller(adapter.language!),
          AdapterOptions(
              resolveObject: adapterResolve,
              resolveType: adapterSearchResult.resolve));

      // return response based on the result
      return switch (result) {
        AdapterErrorResult() => Response(result.statusCode,
              body: switch (result.responseType) {
                ResponseType.json => jsonEncode(result.error.toJson()),
                ResponseType.xml => mapToXml(result.error.toJson()),
                _ => result.error.toString(),
              },
              headers: {
                'Content-Type': switch (result.responseType) {
                  ResponseType.json => 'application/json',
                  ResponseType.archive => 'application/octet-stream',
                  ResponseType.xml => 'application/xml',
                },
              }),
        AdapterMetaResult() => Response.ok(result.body.toJson(), headers: {
            'Content-Type': 'application/json',
          }),
        AdapterArchiveResult() => Response.ok(result.archive, headers: {
            'Content-Type': result.contentType,
            'Content-Disposition': 'attachment; filename=${result.name}',
            'Transfer-Encoding': 'chunked',
          }),
      };
    } on AdapterException catch (_) {
      // could not find adapter
      return Response.notFound('unsupported package manager');
    } on Exception catch (e) {
      return Response.notFound('error: $e');
    }
  };
}

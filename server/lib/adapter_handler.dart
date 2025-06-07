import 'dart:convert';
import 'package:pritt_server/pritt_server.dart';
import 'package:pritt_server/src/main/adapter/adapter/exception.dart';
import 'package:pritt_server/src/main/adapter/adapter/interface.dart';
import 'package:pritt_server/src/main/adapter/adapter/request_options.dart';
import 'package:pritt_server/src/main/adapter/adapter/resolve.dart';
import 'package:pritt_server/src/main/adapter/adapter/result.dart';
import 'package:pritt_server/src/main/crs/crs.dart';
import 'package:pritt_server/src/utils/resolve.dart';
import 'package:pritt_server/src/utils/xml.dart';
import 'package:shelf/shelf.dart';

Handler adapterHandler(CoreRegistryService crs) {
  return (Request req) async {
    try {
      final adapterResolve = getAdapterResolveObject(req);

      // check through the core adapters first
      ({
        AdapterInterface adapter,
        AdapterResolveType resolve
      })? adapterSearchResult = registry.findInCore(adapterResolve);
      adapterSearchResult ??=
          await registry.find(adapterResolve, checkedCore: true);

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
                'Content-Type': result.responseType.mimeType,
              }),
        AdapterMetaResult() => Response.ok(
              result is AdapterMetaJsonResult
                  ? result.body.toJson()
                  : switch (result.responseType) {
                      ResponseType.json => result.body.toJson(),
                      ResponseType.xml => mapToXml(result.body.toJson()),
                      _ => result.body.toString()
                    },
              headers: {
                'Content-Type': result is AdapterMetaJsonResult
                    ? 'application/json'
                    : result.responseType.contentType,
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

import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import 'pritt_server.dart';
import 'src/main/adapter/adapter/adapter_base_result.dart';
import 'src/main/adapter/adapter/exception.dart';
import 'src/main/adapter/adapter/interface.dart';
import 'src/main/adapter/adapter/request_options.dart';
import 'src/main/adapter/adapter/resolve.dart';
import 'src/main/adapter/adapter/result.dart';
import 'src/main/adapter/adapter/adapter_base_result.dart';
import 'src/main/cas/result.dart';
import 'src/main/crs/crs.dart';
import 'src/utils/resolve.dart';
import 'src/utils/xml.dart';

Handler adapterHandler(CoreRegistryService crs) {
  return (Request req) async {
    try {
      print(req.headers);
      print(req.headersAll);
      final adapterResolve = getAdapterResolveObject(req);

      // check through the core adapters first
      ({AdapterInterface adapter, AdapterResolveType resolve})?
      adapterSearchResult = registry.findInCore(adapterResolve);
      adapterSearchResult ??= await registry.find(
        adapterResolve,
        checkedCore: true,
      );

      final adapter = adapterSearchResult.adapter;

      // once we get an adapter, we can then begin the adapter life cycle
      final AdapterBaseResult result;
      try {
        result = await adapter.run(
          adapter.language == null ? crs : crs.controller(adapter.language!),
          AdapterOptions(
            resolveObject: adapterResolve,
            resolveType: adapterSearchResult.resolve,
          ),
        );
      } catch (_) {
        rethrow;
      }

      // return response based on the result
      return switch (result) {
        AdapterErrorResult(
          statusCode: final code,
          responseType: final responseType,
          error: final e,
        ) =>
          Response(
            code,
            body: switch (responseType) {
              ResponseType.json => jsonEncode(e.toJson()),
              ResponseType.xml => mapToXml(e.toJson()),
              _ => switch (e) {
                String s => s,
                Map<String, dynamic> map => jsonEncode(map),
                List<Map<String, dynamic>> map => jsonEncode(map),
                _ => result.error.toString(),
              },
            },
            headers: {HttpHeaders.contentTypeHeader: responseType.mimeType},
          ),
        CoreAdapterMetaJsonResult() => Response.ok(
          jsonEncode(result.body.toJson()),
          headers: {HttpHeaders.contentTypeHeader: result.contentType},
        ),
        AdapterMetaResult(responseType: final responseType, body: final body) =>
          Response.ok(
            switch (responseType) {
              ResponseType.json => jsonEncode(body),
              ResponseType.xml => mapToXml(body.toJson()),
              _ => body.toString(),
            },
            headers: {
              HttpHeaders.contentTypeHeader: switch (body) {
                Map<String, dynamic>() ||
                List<Map<String, dynamic>>() => 'application/json',
                _ => responseType.contentType,
              },
            },
          ),
        AdapterArchiveResult() => Response.ok(
          result.archive,
          headers: {
            HttpHeaders.contentTypeHeader: result.contentType,
            HttpHeaders.contentDisposition:
                'attachment; filename=${result.name}',
          },
        ),
        AdapterBaseResult() => Response.ok(
          null,
          headers: {
            HttpHeaders.contentTypeHeader: result.responseType.contentType,
          },
        ),
      };
    } on AdapterException catch (_) {
      // could not find adapter
      return Response.notFound('unsupported package manager');
    } on Exception catch (e) {
      return Response.notFound('error: $e');
    }
  };
}

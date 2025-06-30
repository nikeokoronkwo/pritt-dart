import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import 'pritt_server.dart';
import 'src/main/adapter/adapter/exception.dart';
import 'src/main/adapter/adapter/interface.dart';
import 'src/main/adapter/adapter/request_options.dart';
import 'src/main/adapter/adapter/resolve.dart';
import 'src/main/adapter/adapter/result.dart';
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
      ({
        AdapterInterface adapter,
        AdapterResolveType resolve
      })? adapterSearchResult = registry.findInCore(adapterResolve);
      adapterSearchResult ??=
          await registry.find(adapterResolve, checkedCore: true);

      final adapter = adapterSearchResult.adapter;

      // once we get an adapter, we can then begin the adapter life cycle
      final AdapterResult result;
      try {
        result = await adapter.run(
            adapter.language == null ? crs : crs.controller(adapter.language!),
            AdapterOptions(
                resolveObject: adapterResolve,
                resolveType: adapterSearchResult.resolve));
      } catch (e, stackTrace) {
        print('$e -- $stackTrace');
        rethrow;
      }

      print(result is AdapterMetaJsonResult
          ? jsonEncode(result.body.toJson())
          : '');
      print(result);

      // return response based on the result
      return switch (result) {
        AdapterErrorResult() => Response(result.statusCode,
              body: switch (result.responseType) {
                ResponseType.json => jsonEncode(result.error.toJson()),
                ResponseType.xml => mapToXml(result.error.toJson()),
                _ => switch (result.error) {
                  String s => s,
                  Map<String, dynamic> map => jsonEncode(map),
                  List<Map<String, dynamic>> map => jsonEncode(map),
                  _ => result.error.toString()
                },
              },
              headers: {
                HttpHeaders.contentTypeHeader: result.responseType.mimeType,
              }),
        AdapterMetaResult() => Response.ok(
              switch (result) {
                AdapterMetaJsonResult() => jsonEncode(result.body.toJson()),
                _ => switch (result.responseType) {
                  ResponseType.json => jsonEncode(result.body),
                  ResponseType.xml => mapToXml(result.body.toJson()),
                  _ => result.body.toString()
                }
              },
              
              headers: {
                HttpHeaders.contentTypeHeader: result is AdapterMetaJsonResult ? result.contentType : switch (result.body) {
                  Map<String, dynamic>() || List<Map<String, dynamic>>() => 'application/json',
                  _ => result.responseType.contentType,
                }
              }),
        AdapterArchiveResult() => Response.ok(result.archive, headers: {
            HttpHeaders.contentTypeHeader: result.contentType,
            HttpHeaders.contentDisposition:
                'attachment; filename=${result.name}',
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

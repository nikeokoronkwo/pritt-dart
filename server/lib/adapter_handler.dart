import 'dart:convert';
import 'dart:io';

import 'package:pritt_adapter/pritt_adapter.dart';
import 'package:pritt_server_core/pritt_server_core.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_proxy/shelf_proxy.dart';

import 'pritt_server.dart';
import 'src/resolve.dart';
import 'src/utils/extensions.dart';
import 'src/xml.dart';

Handler adapterHandler(CoreRegistryService crs, {bool proxy = false}) {
  return proxy ? _adapterWithProxyHandler(crs) : _adapterHandler(crs);
}

Handler _adapterHandler(CoreRegistryService crs) {
  return (Request req) async {
    try {
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
          adapter.language == null
              ? crs
              : await crs.controller(
                  adapter.language!,
                  adapterResolve.authToken,
                ),
          AdapterOptions(
            resolveObject: adapterResolve,
            resolveType: adapterSearchResult.resolve,
          ),
        );
      } catch (_) {
        rethrow;
      }

      // return response based on the result
      return _handleAdapterResult(result);
    } on AdapterException catch (_) {
      // could not find adapter
      return Response.notFound('unsupported package manager');
    } on Exception catch (e) {
      return Response.notFound('error: $e');
    }
  };
}

Handler _adapterWithProxyHandler(CoreRegistryService crs) {
  return (Request req) async {
    try {
      final adapterResolve = getAdapterResolveObject(req);

      // check through the core adapters first
      ({AdapterInterface adapter, AdapterResolveType resolve})?
      adapterSearchResult = registry.findInCore(adapterResolve);
      adapterSearchResult ??= await registry.find(
        adapterResolve,
        checkedCore: true,
      );

      final adapter = adapterSearchResult.adapter;

      Handler adapterProxyHandler;
      if (adapter.proxyEndpoints.singleOrNull case final singleProxyEndpoint?) {
        adapterProxyHandler = proxyHandler(singleProxyEndpoint);
      } else {
        final proxyCascade = Cascade();
        for (final endpoint in adapter.proxyEndpoints) {
          proxyCascade.add(proxyHandler(endpoint));
        }
        adapterProxyHandler = proxyCascade.handler;
      }

      return Cascade(statusCodes: [400, 401, 404, 405])
          .add((req) async {
            // once we get an adapter, we can then begin the adapter life cycle
            final AdapterBaseResult result;
            try {
              result = await adapter.run(
                adapter.language == null
                    ? crs
                    : await crs.controller(
                        adapter.language!,
                        adapterResolve.authToken,
                      ),
                AdapterOptions(
                  resolveObject: adapterResolve,
                  resolveType: adapterSearchResult!.resolve,
                ),
              );
            } on CRSException catch (e) {
              return switch (e.type) {
                CRSExceptionType.UNAUTHORIZED ||
                CRSExceptionType.USER_NOT_FOUND => Response.unauthorized(
                  e.message,
                ),
                CRSExceptionType.PACKAGE_NOT_FOUND ||
                CRSExceptionType.VERSION_NOT_FOUND ||
                CRSExceptionType.SCOPE_NOT_FOUND => Response.notFound(
                  e.message,
                ),
                _ => Response.badRequest(body: e.message),
              };
            } catch (_) {
              rethrow;
            }

            // return response based on the result
            return _handleAdapterResult(result);
          })
          .add(adapterProxyHandler)
          .handler(req);
    } on AdapterException catch (_) {
      // could not find adapter
      return Response.notFound('unsupported package manager');
    } on Exception catch (e) {
      return Response.notFound('error: $e');
    }
  };
}

Response _handleAdapterResult(AdapterBaseResult result) {
  return switch (result) {
    AdapterErrorResult(
      statusCode: final code,
      responseType: final responseType,
      error: final e,
      headers: final extraHeaders,
    ) =>
      Response(
        code,
        body: switch (responseType) {
          ResponseType.json => jsonEncode(e.toJson()),
          ResponseType.xml => mapToXml(e.toJson()),
          ResponseTypeBase(contentType: final contentType)
              when contentType.endsWith('+json') =>
            jsonEncode(e.toJson()),
          _ => switch (e) {
            final String s => s,
            final Map<String, dynamic> map => jsonEncode(map),
            final List<Map<String, dynamic>> map => jsonEncode(map),
            _ => result.error.toString(),
          },
        },
        headers: {
          ...extraHeaders.nonNulls,
          HttpHeaders.contentTypeHeader: responseType.contentType,
        },
      ),
    CoreAdapterMetaJsonResult(headers: final extraHeaders) => Response.ok(
      jsonEncode(result.body.toJson()),
      headers: {
        ...extraHeaders.nonNulls,
        HttpHeaders.contentTypeHeader: result.contentType,
      },
    ),
    AdapterMetaResult(
      responseType: final responseType,
      body: final body,
      headers: final extraHeaders,
    ) =>
      Response.ok(
        switch (responseType) {
          ResponseType.json => jsonEncode(body),
          ResponseType.xml => mapToXml(body.toJson()),
          ResponseTypeBase(contentType: final contentType)
              when contentType.endsWith('+json') =>
            jsonEncode(body),
          _ => body.toString(),
        },
        headers: {
          ...extraHeaders.nonNulls,
          HttpHeaders.contentTypeHeader: switch (body) {
            Map<String, dynamic>() ||
            List<Map<String, dynamic>>() => 'application/json',
            _ => responseType.contentType,
          },
        },
      ),
    AdapterArchiveResult(headers: final extraHeaders) => Response.ok(
      result.archive,
      headers: {
        ...extraHeaders.nonNulls,
        HttpHeaders.contentTypeHeader: result.contentType,
        HttpHeaders.contentDisposition: 'attachment; filename=${result.name}',
      },
    ),
    AdapterBaseResult(headers: final extraHeaders) => Response.ok(
      null,
      headers: {
        ...extraHeaders.nonNulls,
        HttpHeaders.contentTypeHeader: result.responseType.contentType,
      },
    ),
  };
}

import 'dart:io';

import 'package:pritt_adapter/pritt_adapter.dart';
import 'package:pritt_server_core/pritt_server_core.dart';
import 'package:shelf/shelf.dart';

AdapterResolveObject getAdapterResolveObject(Request request) {
  return AdapterResolveObject(
    uri: request.requestedUri,
    method: getMethodFromString(request.method),
    maxAge: int.tryParse(request.headers['max-age'] ?? ''),
    userAgent: getUserAgentFromHeader(request.headers),
    authorization:
        request.headers[HttpHeaders.authorizationHeader]?.startsWith(
              'Bearer ',
            ) ??
            false
        ? request.headers[HttpHeaders.authorizationHeader]!.substring(7)
        : null,
  );
}

RequestMethod getMethodFromString(String method) {
  final cleanedMethod = method.toLowerCase();
  return switch (cleanedMethod) {
    'get' => RequestMethod.GET,
    'post' => RequestMethod.DELETE,
    'put' => RequestMethod.PUT,
    'delete' => RequestMethod.DELETE,
    _ => throw Exception('Unsupported Request Method $method'),
  };
}

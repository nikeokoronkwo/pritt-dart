// ignore_for_file: constant_identifier_names
import 'dart:async';
import 'dart:typed_data';

import 'package:pritt_cli/src/client/authentication.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String url;
  Authentication? authentication;

  http.Client client = http.Client();

  final _headers = <String, String>{};
  Map<String, String> get headers => _headers;

  void addHeaderEntry(String key, String value) {
    _headers[key] = value;
  }

  ApiClient({this.url = 'http://localhost:8080', this.authentication});

  Future<http.BaseResponse> request(
    String path,
    Method method,
    QueryParams queryParams,
    String? hash,
    Object? body, {
    String? contentType,
    bool streamResponse = false,
    Map<String, String>? headerParams,
    Map<String, String>? formParams,
  }) async {
    headerParams ??= {};
    await authentication?.apply(queryParams, headerParams);

    headerParams.addAll(_headers);
    if (contentType != null) {
      headerParams['Content-Type'] = contentType;
    }

    // handle request
    final stringifiedQueryParams = queryParams.isNotEmpty
        ? '?${queryParams.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}'
        : '';
    final stringifiedHash = hash == null ? '' : '#${Uri.encodeComponent(hash)}';
    final uri = Uri.parse('$url$path$stringifiedQueryParams$stringifiedHash');

    try {
      // TODO: Handle stream requests
      // TODO: Handle binary requests
      if (body is Stream<Uint8List> || body is Stream<List<int>>) {
        final req = http.StreamedRequest(method.name, uri)
          ..sink.addStream(
              body is Stream<List<int>> ? body : (body as Stream<Uint8List>));

        unawaited(req.sink.close());
        return await client.send(req);
      } else if (body is Uint8List || body is List<int>) {
        final req = http.StreamedRequest(method.name, uri)
          ..sink.add(body as List<int>);

        unawaited(req.sink.close());
        return await client.send(req);
      }

      if (streamResponse) {
        final req = http.Request(method.name, uri);
        return await client.send(req);
      }

      return await switch (method) {
        Method.GET => client.get(uri, headers: headerParams),
        Method.POST => client.post(uri, headers: headerParams, body: body),
        Method.PUT => client.put(uri, headers: headerParams, body: body),
        Method.DELETE => client.delete(uri, headers: headerParams, body: body),
      };
    } catch (e) {
      rethrow;
    }
  }
}

enum Method { GET, POST, PUT, DELETE }

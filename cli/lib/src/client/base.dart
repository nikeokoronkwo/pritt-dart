// ignore_for_file: constant_identifier_names
import 'dart:async';

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

  FutureOr<http.Response> request(
      String path,
      Method method,
      QueryParams queryParams,
      String? hash,
      Object? body,
      Map<String, String> headerParams,
      Map<String, String> formParams,
      [String? contentType]) async {
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

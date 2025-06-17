import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class Event {
  Request request;
  final ResponseBuilder _responseBuilder = ResponseBuilder();
  Response? _response;

  Event.fromRequest(this.request);

  Response Function(Object? body) get responseFunc => _responseBuilder.build();
}

class ResponseBuilder {
  int statusCode = 200;

  Map<String, Object> headers = {};

  ResponseBuilder();

  Response Function(Object? body) build() {
    return (body) => Response(statusCode, body: body, headers: headers);
  }
}

Stream<List<int>> getStreamedBody(Event e) {
  return e.request.read();
}

Future<Uint8List> getBinaryBody(Event e) async {
  return await e.request
      .read()
      .fold<BytesBuilder>(
        BytesBuilder(),
        (builder, data) => builder..add(data),
      )
      .then((b) => b.toBytes());
}

void setResponseCode(Event e, int statusCode) {
  e._responseBuilder.statusCode = statusCode;
}

Uri getUrl(Event e) {
  return e.request.url;
}

Map<String, String> getQueryParams(Event e) {
  return e.request.url.queryParameters;
}

String getHeader(Event e, String name) {
  var headerValue = e.request.headers[name];
  if (headerValue != null) {
    return headerValue;
  } else {
    throw Exception('Could not find a value for the header $name');
  }
}

Map<String, String> getHeaders(Event e) => e.request.headers;

Object getParams(Event e, String name) {
  var paramValue = e.request.params[name];
  if (paramValue != null) {
    if (paramValue.contains('/')) return paramValue.split('/');
    if (int.tryParse(paramValue) != null) return int.parse(paramValue);
    if (bool.tryParse(paramValue) != null) return bool.parse(paramValue);
    return paramValue;
  } else {
    throw Exception('Could not find a value for the parameter $name');
  }
}

Future<T> getBody<T extends Object>(Event e, T Function(String) toBody) async {
  final body = await e.request.readAsString();
  return toBody(body);
}

Future<Map<String, dynamic>> getJsonBody(Event e) async {
  return json.decode(await e.request.readAsString());
}

String? getUserAgent(Event e) {
  return e.request.headers[HttpHeaders.userAgentHeader];
}

void setResponse(Event e, Response res) {
  e._response = res;
}

typedef EventHandler<T extends Object?> = FutureOr<T> Function(Event);

Handler defineRequestHandler<T extends Object?>(EventHandler<T> handler) {
  return (Request req) async {
    var event = Event.fromRequest(req);
    final response = await handler(event);

    if (event._response != null) return event._response!;

    switch (response) {
      case null:
        return event.responseFunc(null);
      case String():
        return event.responseFunc(response);
      case int():
        return event.responseFunc(response);
      case Map():
        return event.responseFunc(jsonEncode(response));
      case List<Map>():
        return event.responseFunc(jsonEncode(response));
      case Stream<List<int>>():
        event._responseBuilder.headers
            .putIfAbsent('Content-Type', () => 'application/octet-stream');
        return event.responseFunc(response);
      case Uint8List():
        event._responseBuilder.headers
            .putIfAbsent('Content-Type', () => 'application/octet-stream');
        return event.responseFunc(response);
      default:
        return event.responseFunc(response);
    }
  };
}

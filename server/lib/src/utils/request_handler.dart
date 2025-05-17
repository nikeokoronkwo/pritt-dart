import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class Event {
  Request request;
  ResponseBuilder _responseBuilder = ResponseBuilder();
  Response? _response;

  Event.fromRequest(this.request);

  Response Function(Object body) get responseFunc => _responseBuilder.build();
}

class ResponseBuilder {
  int statusCode = 200;

  Map<String, Object> headers = {};

  ResponseBuilder();

  Response Function(Object body) build() {
    return (body) => Response(statusCode, body: body, headers: headers);
  }
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

String getParams(Event e, String name) {
  var paramValue = e.request.params[name];
  if (paramValue != null) {
    return paramValue;
  } else {
    throw Exception('Could not find a value for the parameter $name');
  }
}

void setResponse(Event e, Response res) {
  e._response = res;
}

typedef EventHandler<T> = FutureOr<T> Function(Event);

Handler defineRequestHandler<T>(EventHandler handler) {
  return (Request req) async {
    var event = Event.fromRequest(req);
    final response = await handler(event);

    if (event._response != null) return event._response!;

    return switch (response) {
      String() => event.responseFunc(response),
      Map() => event.responseFunc(jsonEncode(response)),
      List<Map>() => event.responseFunc(response),
      _ => event.responseFunc(response)
    };
  };
}

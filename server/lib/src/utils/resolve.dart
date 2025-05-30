import 'package:shelf/shelf.dart';

import '../main/adapter/adapter/resolve.dart';
import '../main/utils/user_agent.dart';

AdapterResolveObject getAdapterResolveObject(Request request) {
  return AdapterResolveObject(
    uri: request.url,
    method: getMethodFromString(request.method),
    maxAge: int.tryParse(request.headers['max-age'] ?? ''),
    userAgent: getUserAgentFromHeader(request.headers),
  );
}

UserAgent getUserAgentFromHeader(Map<String, String> header) {
  return UserAgent.fromRaw(
      header.map((k, v) => MapEntry(k.toLowerCase(), v))['user-agent'] ?? '');
}

RequestMethod getMethodFromString(String method) {
  final cleanedMethod = method.toLowerCase();
  return switch (cleanedMethod) {
    'get' => RequestMethod.GET,
    'post' => RequestMethod.DELETE,
    'put' => RequestMethod.PUT,
    'delete' => RequestMethod.DELETE,
    _ => throw Exception('Unsupported Request Method $method')
  };
}

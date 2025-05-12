// ignore_for_file: constant_identifier_names

import '../shared/user_agent.dart';

enum RequestMethod { GET, POST, PUT, DELETE }

/// An object containing important information used for adapters to be able to distinguish and make requests for packages from the registry
class AdapterResolveObject {
  /// the path of the request, as is
  String path;

  /// the request method
  RequestMethod method;

  /// The return type of the request, as a string from the `accept` header
  String accept;

  /// The value of the keep-alive header
  int? maxAge;

  /// The query parameters
  Map<String, String> query;

  final Map<String, dynamic> _meta = {};
  Map<String, dynamic> get meta => _meta;

  void addMeta(String key, String value) => _meta[key] = value;

  /// User agent information
  UserAgent userAgent;

  AdapterResolveObject(
      {required Uri uri,
      this.maxAge,
      required this.method,
      this.accept = 'application/json',
      this.query = const {},
      required this.userAgent})
      : path = uri.path;
}

enum AdapterResolve {
  meta,
  archive,
  other,
  none;

  bool get isResolved => this != none;
}

class AdapterResult {}

class AdapterException implements Exception {}

/// A base interface shared between adapters
abstract interface class AdapterInterface {
  /// Run an adapter
  Future run();
}

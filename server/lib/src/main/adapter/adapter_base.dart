// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:mime/mime.dart';

import '../crs/interfaces.dart';
import '../shared/user_agent.dart';

enum RequestMethod { GET, POST, PUT, DELETE }

/// An object containing important information used for adapters to be able to distinguish and make requests for packages from the registry
class AdapterResolveObject {
  /// the path of the request, as is without the forward slash in front
  String path;

  /// the path segments
  List<String> pathSegments;

  /// the url of the current pritt instance
  ///
  /// Use this for modifying any urls that are needed to be made to the registry, rather than guessing the url or accidentally calling the wrong url
  String url;

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
      : path = uri.path,
        pathSegments = uri.pathSegments,
        url =
            '${uri.scheme}://${uri.host}${uri.port == 80 ? '' : ':${uri.port}'}';
}

enum AdapterResolveType {
  meta,
  archive,
  other,
  none;

  bool get isResolved => this != none;
}

sealed class AdapterResult {
  final ResponseType responseType;

  const AdapterResult({this.responseType = ResponseType.json});
}

mixin MetaResult {
  Map<String, dynamic> toJson();
}

// TODO: Custom conversion types for other formats (i.e custom adapter formats)
enum ResponseType {
  json(mimeType: 'application/json'),
  archive(mimeType: 'application/octet-stream'),
  xml(mimeType: 'application/xml');

  final String mimeType;
  const ResponseType({required this.mimeType});
  String get contentType => mimeType;
}

class AdapterErrorResult<T extends MetaResult> extends AdapterResult {
  final T error;
  final int statusCode;

  AdapterErrorResult(this.error, {this.statusCode = 500, super.responseType});
}

class AdapterMetaResult<T extends MetaResult> extends AdapterResult {
  final T body;

  AdapterMetaResult(this.body, {super.responseType});
}

class AdapterArchiveResult<T> extends AdapterResult {
  final Stream<List<int>> archive;
  final String name;
  final String contentType;

  AdapterArchiveResult(this.archive, this.name, {String? contentType})
      : contentType =
            contentType ?? lookupMimeType(name) ?? 'application/octet-stream',
        super(responseType: ResponseType.archive);
}

class AdapterException implements Exception {
  final String message;

  final Object? source;
  AdapterException(this.message, {this.source}) : super();
}

/// A base interface shared between adapters
abstract interface class AdapterInterface {
  String? get language;

  /// Run an adapter
  FutureOr<AdapterResult> run(CRSController crs, AdapterOptions options);
}

class AdapterOptions {
  final AdapterResolveObject resolveObject;
  final AdapterResolveType resolveType;

  const AdapterOptions({
    required this.resolveObject,
    required this.resolveType,
  });

  /// generate an [AdapterRequestObject] from the current options
  AdapterRequestObject toRequestObject() {
    return AdapterRequestObject(
      resolveObject: resolveObject,
      env: resolveObject.meta,
      resolveType: resolveType,
    );
  }
}

class AdapterRequestObject {
  AdapterResolveObject resolveObject;

  Map<String, dynamic> env;

  AdapterResolveType resolveType;

  AdapterRequestObject({
    required this.resolveObject,
    Map<String, dynamic>? env,
    required this.resolveType,
  }) : env = env ?? resolveObject.meta;
}

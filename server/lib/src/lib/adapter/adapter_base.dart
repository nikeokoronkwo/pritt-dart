// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:pritt_server/src/lib/crs/crs.dart';
import 'package:pritt_server/src/lib/crs/db.dart';
import 'package:pritt_server/src/lib/crs/db/schema.dart';
import 'package:pritt_server/src/lib/crs/fs.dart';
import 'package:pritt_server/src/lib/shared/version.dart';

import '../shared/user_agent.dart';

enum RequestMethod { GET, POST, PUT, DELETE }

/// An object containing important information used for adapters to be able to distinguish and make requests for packages from the registry
class AdapterResolveObject {
  /// the path of the request, as is
  String path;

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
      : path = uri.path, url = '${uri.scheme}://${uri.host}${uri.port == 80 ? '' : ':${uri.port}'}';
}

enum AdapterResolve {
  meta,
  archive,
  other,
  none;

  bool get isResolved => this != none;
}

class AdapterResult {}

mixin MetaResult {
  Map<String, dynamic> toJson();
}

class AdapterMetaResult<T extends MetaResult> extends AdapterResult {
  final T body;

  AdapterMetaResult(this.body);
}

class AdapterArchiveResult<T> extends AdapterResult {
  final Uint8List archive;
  final String name;
  final String contentType;

  AdapterArchiveResult(this.archive, this.name, {String? contentType}) : contentType = contentType ?? lookupMimeType(name) ?? 'application/octet-stream';
}

class AdapterException implements Exception {}

/// A base interface shared between adapters
abstract interface class AdapterInterface {
  /// Run an adapter
  Future run();
}


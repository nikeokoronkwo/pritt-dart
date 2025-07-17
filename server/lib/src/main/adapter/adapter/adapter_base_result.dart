// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

import 'result.dart';

/// shared base result between [CoreAdapterResult] used internally and [CustomAdapterResult]
abstract class AdapterBaseResult {
  abstract final ResponseType responseType;
  const AdapterBaseResult();
}

abstract interface class AdapterMetaResult<T> extends AdapterBaseResult {
  T get body;
}

abstract interface class AdapterArchiveResult extends AdapterBaseResult {
  abstract final String name;

  String get contentType;

  Uint8List? get archive;
}

abstract interface class AdapterErrorResult<T> extends AdapterBaseResult {
  abstract final T error;

  int get statusCode;
}

@JsonEnum(valueField: 'mimeType')
enum ResponseType {
  json(mimeType: 'application/json'),
  archive(mimeType: 'application/octet-stream'),
  xml(mimeType: 'application/xml'),
  plainText(mimeType: 'text/plain'),
  html(mimeType: 'text/html');

  final String mimeType;
  const ResponseType({required this.mimeType});
  String get contentType => mimeType;
}

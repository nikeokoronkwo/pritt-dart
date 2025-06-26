// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:mime/mime.dart';
import '../../utils/mixins.dart';

/// shared base result between [AdapterResult] used internally and [CustomAdapterResult]
abstract class AdapterBaseResult {
  const AdapterBaseResult();
}

sealed class AdapterResult extends AdapterBaseResult {
  final ResponseType responseType;

  const AdapterResult({this.responseType = ResponseType.json}) : super();
}

// TODO: Custom conversion types for other formats (i.e custom adapter formats)
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

class MapConvertible with JsonConvertible {
  final Map<String, dynamic> map;

  MapConvertible(this.map);
  @override
  Map<String, dynamic> toJson() => map;
}

class AdapterErrorResult<T> extends AdapterResult {
  final T error;
  final int statusCode;

  AdapterErrorResult(this.error, {this.statusCode = 500, super.responseType});

  static AdapterErrorResult map(Map<String, dynamic> json,
      {int statusCode = 500, ResponseType? responseType}) {
    return AdapterErrorJsonResult(MapConvertible(json),
        statusCode: statusCode,
        responseType: responseType ?? ResponseType.json);
  }
}

class AdapterErrorJsonResult<T extends JsonConvertible>
    extends AdapterErrorResult<T> {
  AdapterErrorJsonResult(super.error, {super.statusCode, super.responseType});
}

class AdapterMetaResult<T> extends AdapterResult {
  final T body;

  AdapterMetaResult(this.body, {super.responseType});
}

class AdapterMetaJsonResult<T extends JsonConvertible>
    extends AdapterMetaResult<T> {
  String contentType;
  AdapterMetaJsonResult(super.body, {super.responseType, this.contentType = 'application/json'});
}

class AdapterArchiveResult extends AdapterResult {
  final Stream<List<int>> archive;
  final String name;
  final String contentType;

  AdapterArchiveResult(this.archive, this.name, {String? contentType})
      : contentType =
            contentType ?? lookupMimeType(name) ?? 'application/octet-stream',
        super(responseType: ResponseType.archive);
}

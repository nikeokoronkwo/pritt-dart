// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:mime/mime.dart';
import 'package:pritt_server/src/main/utils/mixins.dart';

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
  xml(mimeType: 'application/xml');

  final String mimeType;
  const ResponseType({required this.mimeType});
  String get contentType => mimeType;
}

class AdapterErrorResult<T extends JsonConvertible> extends AdapterResult {
  final T error;
  final int statusCode;

  AdapterErrorResult(this.error, {this.statusCode = 500, super.responseType});
}

class AdapterMetaResult<T extends JsonConvertible> extends AdapterResult {
  final T body;

  AdapterMetaResult(this.body, {super.responseType});
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

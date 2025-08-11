// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:mime/mime.dart';
import '../utils/map_convertible.dart';
import '../utils/mixins.dart';
import 'base_result.dart';

sealed class CoreAdapterResult extends AdapterBaseResult {
  @override
  final ResponseTypeBase responseType;

  const CoreAdapterResult({this.responseType = ResponseType.json, super.headers = const {}}) : super();
}

class CoreAdapterErrorResult<T> extends CoreAdapterResult
    implements AdapterErrorResult<T> {
  @override
  final T error;

  @override
  final int statusCode;

  CoreAdapterErrorResult(
    this.error, {
    this.statusCode = 500,
    super.responseType,
    super.headers
  });

  static CoreAdapterErrorResult map(
    Map<String, dynamic> json, {
    int statusCode = 500,
    ResponseType? responseType,
  }) {
    return CoreAdapterErrorJsonResult(
      MapConvertible(json),
      statusCode: statusCode,
      responseType: responseType ?? ResponseType.json,
    );
  }
}

class CoreAdapterErrorJsonResult<T extends JsonConvertible>
    extends CoreAdapterErrorResult<T> {
  CoreAdapterErrorJsonResult(
    super.error, {
    super.statusCode,
    super.responseType,
    super.headers
  });
}

class CoreAdapterMetaResult<T> extends CoreAdapterResult
    implements AdapterMetaResult<T> {
  @override
  final T body;

  CoreAdapterMetaResult(this.body, {super.responseType, super.headers});
}

class CoreAdapterMetaJsonResult<T extends JsonConvertible>
    extends CoreAdapterMetaResult<T> {
  String contentType;
  CoreAdapterMetaJsonResult(
    super.body, {
    super.responseType,
    this.contentType = 'application/json',
    super.headers
  });
}

class CoreAdapterArchiveResult extends CoreAdapterResult {
  final Stream<List<int>> archive;
  final String name;
  final String contentType;

  CoreAdapterArchiveResult(this.archive, this.name, {String? contentType})
    : contentType =
          contentType ?? lookupMimeType(name) ?? 'application/octet-stream',
      super(responseType: ResponseType.archive);
}

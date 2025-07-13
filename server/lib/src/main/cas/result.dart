import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

import '../adapter/adapter/adapter_base_result.dart';
import 'converters.dart';

part 'result.g.dart';

sealed class CustomAdapterResult implements AdapterBaseResult {
  @override
  final ResponseType responseType;

  const CustomAdapterResult({this.responseType = ResponseType.json}) : super();
}

@JsonSerializable()
class CustomAdapterMetaResult extends CustomAdapterResult
    implements AdapterMetaResult {
  @override
  final dynamic body;

  CustomAdapterMetaResult(this.body, {super.responseType});

  factory CustomAdapterMetaResult.fromJson(Map<String, dynamic> json) =>
      _$CustomAdapterMetaResultFromJson(json);

  Map<String, dynamic> toJson() => _$CustomAdapterMetaResultToJson(this);
}

@JsonSerializable()
class CustomAdapterArchiveResult extends CustomAdapterResult
    implements AdapterArchiveResult {
  /// The name of the archive, to use to get from cache if possible
  @JsonKey(name: 'target')
  final String archiveTarget;

  @override
  final String name;

  @override
  final String contentType;

  @override
  @Uint8ListConverter()
  Uint8List? archive;

  CustomAdapterArchiveResult({
    required this.name,
    required this.contentType,
    required this.archiveTarget,
    this.archive,
  }) : super(responseType: ResponseType.archive);

  factory CustomAdapterArchiveResult.fromJson(Map<String, dynamic> json) =>
      _$CustomAdapterArchiveResultFromJson(json);

  Map<String, dynamic> toJson() => _$CustomAdapterArchiveResultToJson(this);
}

@JsonSerializable(createFactory: false)
class CustomAdapterErrorResult extends CustomAdapterResult
    implements AdapterErrorResult<Object?> {
  @override
  final Object? error;

  final String message;

  @override
  final int statusCode;

  CustomAdapterErrorResult(
    this.error, {
    required this.message,
    this.statusCode = 500,
    super.responseType,
  });

  Map<String, dynamic> toJson() => _$CustomAdapterErrorResultToJson(this);
}

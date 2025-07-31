// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomAdapterMetaResult _$CustomAdapterMetaResultFromJson(
  Map<String, dynamic> json,
) => CustomAdapterMetaResult(
  json['body'],
  responseType:
      $enumDecodeNullable(_$ResponseTypeEnumMap, json['responseType']) ??
      ResponseType.json,
);

Map<String, dynamic> _$CustomAdapterMetaResultToJson(
  CustomAdapterMetaResult instance,
) => <String, dynamic>{
  'responseType': _$ResponseTypeEnumMap[instance.responseType]!,
  'body': instance.body,
};

const _$ResponseTypeEnumMap = {
  ResponseType.json: 'application/json',
  ResponseType.archive: 'application/octet-stream',
  ResponseType.xml: 'application/xml',
  ResponseType.plainText: 'text/plain',
  ResponseType.html: 'text/html',
};

CustomAdapterArchiveResult _$CustomAdapterArchiveResultFromJson(
  Map<String, dynamic> json,
) => CustomAdapterArchiveResult(
  name: json['name'] as String,
  contentType: json['contentType'] as String,
  archiveTarget: json['target'] as String,
  archive: const Uint8ListConverter().fromJson(json['archive'] as List<int>?),
);

Map<String, dynamic> _$CustomAdapterArchiveResultToJson(
  CustomAdapterArchiveResult instance,
) => <String, dynamic>{
  'target': instance.archiveTarget,
  'name': instance.name,
  'contentType': instance.contentType,
  'archive': const Uint8ListConverter().toJson(instance.archive),
};

Map<String, dynamic> _$CustomAdapterErrorResultToJson(
  CustomAdapterErrorResult instance,
) => <String, dynamic>{
  'responseType': _$ResponseTypeEnumMap[instance.responseType]!,
  'error': instance.error,
  'message': instance.message,
  'statusCode': instance.statusCode,
};

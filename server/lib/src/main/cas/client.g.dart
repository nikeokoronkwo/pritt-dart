// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CASMessage _$CASMessageFromJson(Map json) => CASMessage(
      messageType: $enumDecode(_$CASMessageTypeEnumMap, json['message_type']),
    );

Map<String, dynamic> _$CASMessageToJson(CASMessage instance) =>
    <String, dynamic>{
      'message_type': _$CASMessageTypeEnumMap[instance.messageType]!,
    };

const _$CASMessageTypeEnumMap = {
  CASMessageType.crsRequest: 'crsRequest',
  CASMessageType.crsResponse: 'crsResponse',
  CASMessageType.metaRequest: 'metaRequest',
  CASMessageType.metaResponse: 'metaResponse',
  CASMessageType.archiveRequest: 'archiveRequest',
  CASMessageType.archiveResponse: 'archiveResponse',
};

CASRequest _$CASRequestFromJson(Map json) => CASRequest(
      id: json['id'] as String,
      method: json['method'] as String,
      params: Map<String, dynamic>.from(json['params'] as Map),
    );

CASResponse _$CASResponseFromJson(Map json) => CASResponse(
      id: json['id'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$CASResponseToJson(CASResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'data': instance.data,
      'error': instance.error,
    };

CASBuiltResponse<T> _$CASBuiltResponseFromJson<T extends Jsonable>(
  Map json,
  T Function(Object? json) fromJsonT,
) =>
    CASBuiltResponse<T>(
      id: json['id'] as String,
      data: fromJsonT(json['data']),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$CASBuiltResponseToJson<T extends Jsonable>(
  CASBuiltResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'id': instance.id,
      'data': CASBuiltResponse.tToJson(instance.data),
      'error': instance.error,
    };

Map<String, dynamic>
    _$CustomAdapterCompleteResponseToJson<T extends CustomAdapterResult>(
            CustomAdapterCompleteResponse<T> instance) =>
        <String, dynamic>{
          'id': instance.id,
          'data': CASBuiltResponse.tToJson(instance.data),
          'error': instance.error,
          'message_type': _$CASMessageTypeEnumMap[instance.messageType]!,
        };

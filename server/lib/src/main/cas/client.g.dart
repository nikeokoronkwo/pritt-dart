// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CASMessage _$CASMessageFromJson(Map<String, dynamic> json) => CASMessage(
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

CASRequest _$CASRequestFromJson(Map<String, dynamic> json) => CASRequest(
      id: json['id'] as String,
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>,
    );

CASResponse<T> _$CASResponseFromJson<T extends Jsonable>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    CASResponse<T>(
      id: json['id'] as String,
      data: fromJsonT(json['data']),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$CASResponseToJson<T extends Jsonable>(
  CASResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'id': instance.id,
      'data': CASResponse.tToJson(instance.data),
      'error': instance.error,
    };

Map<String, dynamic>
    _$CustomAdapterCompleteResponseToJson<T extends CustomAdapterResult>(
            CustomAdapterCompleteResponse<T> instance) =>
        <String, dynamic>{
          'id': instance.id,
          'data': CASResponse.tToJson(instance.data),
          'error': instance.error,
          'message_type': _$CASMessageTypeEnumMap[instance.messageType]!,
        };

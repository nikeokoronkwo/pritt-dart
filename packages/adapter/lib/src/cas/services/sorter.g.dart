// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sorter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SorterSuccessResponse _$SorterSuccessResponseFromJson(
  Map<String, dynamic> json,
) => SorterSuccessResponse(
  type: $enumDecode(_$AdapterResolveTypeEnumMap, json['result']),
  workerId: json['workerId'] as String,
  adapterId: json['adapterId'] as String,
);

Map<String, dynamic> _$SorterSuccessResponseToJson(
  SorterSuccessResponse instance,
) => <String, dynamic>{
  'workerId': instance.workerId,
  'adapterId': instance.adapterId,
  'result': _$AdapterResolveTypeEnumMap[instance.type]!,
};

const _$AdapterResolveTypeEnumMap = {
  AdapterResolveType.meta: 'meta',
  AdapterResolveType.archive: 'archive',
  AdapterResolveType.none: 'none',
};

SorterFailureResponse _$SorterFailureResponseFromJson(
  Map<String, dynamic> json,
) => SorterFailureResponse(workerId: json['workerId'] as String);

Map<String, dynamic> _$SorterFailureResponseToJson(
  SorterFailureResponse instance,
) => <String, dynamic>{'workerId': instance.workerId};

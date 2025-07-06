// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sorter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SorterResponse _$SorterResponseFromJson(Map json) => SorterResponse(
  type: $enumDecode(_$AdapterResolveTypeEnumMap, json['result']),
  adapterId: json['adapterId'] as String?,
  success: json['success'] as bool,
  workerId: json['workerId'] as String,
);

Map<String, dynamic> _$SorterResponseToJson(SorterResponse instance) =>
    <String, dynamic>{
      'result': _$AdapterResolveTypeEnumMap[instance.type]!,
      'adapterId': instance.adapterId,
      'success': instance.success,
      'workerId': instance.workerId,
    };

const _$AdapterResolveTypeEnumMap = {
  AdapterResolveType.meta: 'meta',
  AdapterResolveType.archive: 'archive',
  AdapterResolveType.none: 'none',
};

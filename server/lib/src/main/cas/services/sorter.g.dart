// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sorter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SorterResponse _$SorterResponseFromJson(Map<String, dynamic> json) =>
    SorterResponse(
      type: $enumDecode(_$AdapterResolveTypeEnumMap, json['type']),
      adapterId: json['adapterId'] as String?,
      success: json['success'] as bool,
      workerId: json['workerId'] as String,
    );

Map<String, dynamic> _$SorterResponseToJson(SorterResponse instance) =>
    <String, dynamic>{
      'type': _$AdapterResolveTypeEnumMap[instance.type]!,
      'adapterId': instance.adapterId,
      'success': instance.success,
      'workerId': instance.workerId,
    };

const _$AdapterResolveTypeEnumMap = {
  AdapterResolveType.meta: 'meta',
  AdapterResolveType.archive: 'archive',
  AdapterResolveType.none: 'none',
};

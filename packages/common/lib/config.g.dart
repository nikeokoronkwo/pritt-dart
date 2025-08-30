// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrittConfig _$PrittConfigFromJson(Map<String, dynamic> json) => PrittConfig(
  contributors: (json['contributors'] as List<dynamic>?)
      ?.map(User.fromJson)
      .toList(),
  private: json['private'] as bool? ?? false,
  name: json['name'] as String?,
  version: json['version'] as String?,
);

Map<String, dynamic> _$PrittConfigToJson(PrittConfig instance) =>
    <String, dynamic>{
      'contributors': instance.contributors,
      'private': instance.private,
      'name': instance.name,
      'version': instance.version,
    };

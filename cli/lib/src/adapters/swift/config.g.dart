// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageSwiftConfig _$PackageSwiftConfigFromJson(Map<String, dynamic> json) =>
    PackageSwiftConfig(
      name: json['name'] as String,
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      version: json['version'] as String,
    );

Map<String, dynamic> _$PackageSwiftConfigToJson(PackageSwiftConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'author': instance.author,
    };

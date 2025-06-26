// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrittAuthMetadata _$PrittAuthMetadataFromJson(Map json) => PrittAuthMetadata(
      name: json['name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$PrittAuthMetadataToJson(PrittAuthMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
    };

APIKeyResult _$APIKeyResultFromJson(Map json) => APIKeyResult(
      apiKey: json['apiKey'] as String,
      keyHash: json['keyHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      prefix: json['prefix'] as String,
      length: (json['length'] as num).toInt(),
    );

Map<String, dynamic> _$APIKeyResultToJson(APIKeyResult instance) =>
    <String, dynamic>{
      'apiKey': instance.apiKey,
      'keyHash': instance.keyHash,
      'createdAt': instance.createdAt.toIso8601String(),
      'prefix': instance.prefix,
      'length': instance.length,
    };

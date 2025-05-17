// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_pkgver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponsePkgVer _$ResponsePkgVerFromJson(Map<String, dynamic> json) =>
    ResponsePkgVer(
      name: json['name'] as String,
      version: json['version'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      info: json['info'] as Map<String, dynamic>,
      env: json['env'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
      signatures: (json['signatures'] as List<dynamic>)
          .map((e) => Signature.fromJson(e as Map<String, dynamic>))
          .toList(),
      deprecated: json['deprecated'] as bool?,
      yanked: json['yanked'] as bool?,
    );

Map<String, dynamic> _$ResponsePkgVerToJson(ResponsePkgVer instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
      'info': instance.info,
      'env': instance.env,
      'metadata': instance.metadata,
      'signatures': instance.signatures,
      'deprecated': instance.deprecated,
      'yanked': instance.yanked,
    };

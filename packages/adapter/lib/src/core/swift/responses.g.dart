// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwiftRelease _$SwiftReleaseFromJson(Map<String, dynamic> json) => SwiftRelease(
  uri: Uri.parse(json['uri'] as String),
  problem: json['problem'] == null
      ? null
      : SwiftError.fromJson(json['problem'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SwiftReleaseToJson(SwiftRelease instance) =>
    <String, dynamic>{
      'uri': instance.uri.toString(),
      'problem': instance.problem,
    };

SwiftPackage _$SwiftPackageFromJson(Map<String, dynamic> json) => SwiftPackage(
  id: json['id'] as String,
  version: json['version'] as String,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  resources: (json['resources'] as List<dynamic>)
      .map((e) => SwiftResource.fromJson(e as Map<String, dynamic>))
      .toList(),
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$SwiftPackageToJson(SwiftPackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'version': instance.version,
      'metadata': instance.metadata,
      'resources': instance.resources,
      'publishedAt': instance.publishedAt?.toIso8601String(),
    };

SwiftResource _$SwiftResourceFromJson(Map<String, dynamic> json) =>
    SwiftResource(checksum: json['checksum'] as String);

Map<String, dynamic> _$SwiftResourceToJson(SwiftResource instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'checksum': instance.checksum,
    };

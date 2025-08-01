// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartMetaResult _$DartMetaResultFromJson(Map<String, dynamic> json) =>
    DartMetaResult(
      name: json['name'] as String,
      latest: DartPackage.fromJson(json['latest'] as Map<String, dynamic>),
      versions: (json['versions'] as List<dynamic>)
          .map((e) => DartPackage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DartMetaResultToJson(DartMetaResult instance) =>
    <String, dynamic>{
      'name': instance.name,
      'latest': instance.latest,
      'versions': instance.versions,
    };

DartPackage _$DartPackageFromJson(Map<String, dynamic> json) => DartPackage(
  version: json['version'] as String,
  pubspec: PubSpec.fromJson(json['pubspec'] as Map<String, dynamic>),
  archiveUrl: json['archive_url'] as String,
  archiveHash: json['archive_sha256'] as String,
  published: DateTime.parse(json['published'] as String),
);

Map<String, dynamic> _$DartPackageToJson(DartPackage instance) =>
    <String, dynamic>{
      'version': instance.version,
      'pubspec': instance.pubspec,
      'archive_url': instance.archiveUrl,
      'archive_sha256': instance.archiveHash,
      'published': instance.published.toIso8601String(),
    };

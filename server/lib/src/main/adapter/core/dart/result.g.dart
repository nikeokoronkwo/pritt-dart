// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartMetaResult _$DartMetaResultFromJson(Map json) => DartMetaResult(
      name: json['name'] as String,
      latest: DartPackage.fromJson(
          Map<String, dynamic>.from(json['latest'] as Map)),
      versions: (json['versions'] as List<dynamic>)
          .map((e) => DartPackage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$DartMetaResultToJson(DartMetaResult instance) =>
    <String, dynamic>{
      'name': instance.name,
      'latest': instance.latest.toJson(),
      'versions': instance.versions.map((e) => e.toJson()).toList(),
    };

DartPackage _$DartPackageFromJson(Map json) => DartPackage(
      version: json['version'] as String,
      pubspec:
          PubSpec.fromJson(Map<String, dynamic>.from(json['pubspec'] as Map)),
      archiveUrl: json['archive_url'] as String,
      archiveHash: json['archive_sha256'] as String,
      published: DateTime.parse(json['published'] as String),
    );

Map<String, dynamic> _$DartPackageToJson(DartPackage instance) =>
    <String, dynamic>{
      'version': instance.version,
      'pubspec': instance.pubspec.toJson(),
      'archive_url': instance.archiveUrl,
      'archive_sha256': instance.archiveHash,
      'published': instance.published.toIso8601String(),
    };

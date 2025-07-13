// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$PackageToJson(Package instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'version': instance.version,
  'author': const UserJsonConverter().toJson(instance.author),
  'language': instance.language,
  'updated': instance.updated.toIso8601String(),
  'created': instance.created.toIso8601String(),
  'vcs': _$VCSEnumMap[instance.vcs]!,
  'vcsUrl': instance.vcsUrl?.toString(),
  'archive': instance.archive.toString(),
  'license': instance.license,
  'scoped': instance.scoped,
  'scope': instance.scope,
};

const _$VCSEnumMap = {
  VCS.git: 'git',
  VCS.svn: 'svn',
  VCS.fossil: 'fossil',
  VCS.mercurial: 'mercurial',
  VCS.other: 'other',
};

Map<String, dynamic> _$PackageVersionsToJson(PackageVersions instance) =>
    <String, dynamic>{
      'package': instance.package.toJson(),
      'version': instance.version,
      'versionType': _$VersionTypeEnumMap[instance.versionType]!,
      'created': instance.created.toIso8601String(),
      'readme': instance.readme,
      'config': instance.config,
      'configName': instance.configName,
      'info': instance.info,
      'env': instance.env,
      'metadata': instance.metadata,
      'archive': instance.archive.toString(),
      'hash': instance.hash,
      'signatures': instance.signatures.map((e) => e.toJson()).toList(),
      'integrity': instance.integrity,
      'isDeprecated': instance.isDeprecated,
      'deprecationMessage': instance.deprecationMessage,
      'isYanked': instance.isYanked,
    };

const _$VersionTypeEnumMap = {
  VersionType.major: 'major',
  VersionType.experimental: 'experimental',
  VersionType.beta: 'beta',
  VersionType.next: 'next',
  VersionType.rc: 'rc',
  VersionType.canary: 'canary',
  VersionType.other: 'other',
};

Signature _$SignatureFromJson(Map json) => Signature(
  publicKeyId: json['publicKeyId'] as String,
  signature: json['signature'] as String,
  created: DateTime.parse(json['created'] as String),
);

Map<String, dynamic> _$SignatureToJson(Signature instance) => <String, dynamic>{
  'publicKeyId': instance.publicKeyId,
  'signature': instance.signature,
  'created': instance.created.toIso8601String(),
};

Map<String, dynamic> _$PublishingTaskToJson(PublishingTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'user': instance.user,
      'version': instance.version,
      r'$new': instance.$new,
      'name': instance.name,
      'scope': instance.scope,
      'language': instance.language,
      'config': instance.config,
      'configMap': instance.configMap,
      'env': instance.env,
      'metadata': instance.metadata,
      'vcs': _$VCSEnumMap[instance.vcs]!,
      'vcsUrl': instance.vcsUrl?.toString(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'tarball': instance.tarball?.toString(),
      'message': instance.message,
    };

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.success: 'success',
  TaskStatus.fail: 'fail',
  TaskStatus.expired: 'expired',
  TaskStatus.idle: 'idle',
  TaskStatus.queue: 'queue',
  TaskStatus.error: 'error',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

const _$VCSEnumMap = {
  VCS.git: 'git',
  VCS.svn: 'svn',
  VCS.fossil: 'fossil',
  VCS.mercurial: 'mercurial',
  VCS.other: 'other',
};

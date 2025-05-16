// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Signature _$SignatureFromJson(Map<String, dynamic> json) => Signature(
      publicKeyId: json['publicKeyId'] as String,
      signature: json['signature'] as String,
      created: DateTime.parse(json['created'] as String),
    );

Map<String, dynamic> _$SignatureToJson(Signature instance) => <String, dynamic>{
      'publicKeyId': instance.publicKeyId,
      'signature': instance.signature,
      'created': instance.created.toIso8601String(),
    };

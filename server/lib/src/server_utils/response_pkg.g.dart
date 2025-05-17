// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_pkg.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponsePkg _$ResponsePkgFromJson(Map<String, dynamic> json) => ResponsePkg(
      name: json['name'] as String,
      version: json['version'] as String,
      author: ResponsePkgUser.fromJson(json['author'] as Map<String, dynamic>),
      language: json['language'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ResponsePkgToJson(ResponsePkg instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'author': instance.author,
      'language': instance.language,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

ResponsePkgUser _$ResponsePkgUserFromJson(Map<String, dynamic> json) =>
    ResponsePkgUser(
      name: json['name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$ResponsePkgUserToJson(ResponsePkgUser instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
    };

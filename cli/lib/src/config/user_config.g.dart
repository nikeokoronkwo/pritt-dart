// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCredentials _$UserCredentialsFromJson(Map<String, dynamic> json) =>
    UserCredentials(
      uri: json['uri'] == null ? null : Uri.parse(json['uri'] as String),
      accessToken: json['access_token'] as String,
      accessTokenExpires: DateTime.parse(
        json['access_token_expires'] as String,
      ),
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String,
    );

Map<String, dynamic> _$UserCredentialsToJson(UserCredentials instance) =>
    <String, dynamic>{
      'uri': instance.uri.toString(),
      'device_id': instance.deviceId,
      'access_token': instance.accessToken,
      'user_id': instance.userId,
      'access_token_expires': instance.accessTokenExpires.toIso8601String(),
    };

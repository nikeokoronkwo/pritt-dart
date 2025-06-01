// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthPollSuccessResponse _$AuthPollSuccessResponseFromJson(
        Map<String, dynamic> json) =>
    AuthPollSuccessResponse(
      status: $enumDecode(_$PollStatusEnumMap, json['status']),
      response: json['response'] == null
          ? null
          : PollResponse.fromJson(json['response'] as Map<String, dynamic>),
      id: json['id'] as String,
      accessToken: json['access_token'] as String,
    );

Map<String, dynamic> _$AuthPollSuccessResponseToJson(
        AuthPollSuccessResponse instance) =>
    <String, dynamic>{
      'status': _$PollStatusEnumMap[instance.status]!,
      'response': instance.response,
      'id': instance.id,
      'access_token': instance.accessToken,
    };

const _$PollStatusEnumMap = {
  PollStatus.success: 'success',
  PollStatus.fail: 'fail',
  PollStatus.error: 'error',
  PollStatus.expired: 'expired',
  PollStatus.pending: 'pending',
};

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

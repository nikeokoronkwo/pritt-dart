// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwiftError _$SwiftErrorFromJson(Map<String, dynamic> json) => SwiftError(
  detail: json['detail'] as String,
  title: json['title'] as String?,
);

Map<String, dynamic> _$SwiftErrorToJson(SwiftError instance) =>
    <String, dynamic>{'detail': instance.detail, 'title': instance.title};

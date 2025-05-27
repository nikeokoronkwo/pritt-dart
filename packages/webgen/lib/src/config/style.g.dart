// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WGTStyleColours _$WGTStyleColoursFromJson(Map<String, dynamic> json) =>
    WGTStyleColours(
      primary: json['primary'] as String,
      secondary: json['secondary'] as String?,
      background: json['background'] as String?,
      text: json['text'] as String?,
      accent: json['accent'] as String,
    );

Map<String, dynamic> _$WGTStyleColoursToJson(WGTStyleColours instance) =>
    <String, dynamic>{
      'primary': instance.primary,
      'secondary': instance.secondary,
      'background': instance.background,
      'text': instance.text,
      'accent': instance.accent,
    };

WGTStyleFont _$WGTStyleFontFromJson(Map<String, dynamic> json) => WGTStyleFont(
      family: json['family'] as String,
      size: (json['size'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WGTStyleFontToJson(WGTStyleFont instance) =>
    <String, dynamic>{
      'family': instance.family,
      'size': instance.size,
      'weight': instance.weight,
    };

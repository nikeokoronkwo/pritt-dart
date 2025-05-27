// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebGenTemplateConfig _$WebGenTemplateConfigFromJson(
        Map<String, dynamic> json) =>
    WebGenTemplateConfig(
      name: json['name'] as String,
      style: WGTStyle.fromJson(json['style']),
      icon: json['icon'] as String,
      logo: json['logo'] as String,
      assets:
          (json['assets'] as List<dynamic>).map((e) => e as String).toList(),
      meta: json['meta'] == null
          ? null
          : WGTMeta.fromJson(json['meta'] as Map<String, dynamic>),
      auth: WGTAuth.fromJson(json['auth'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WebGenTemplateConfigToJson(
        WebGenTemplateConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'style': instance.style,
      'icon': instance.icon,
      'logo': instance.logo,
      'assets': instance.assets,
      'meta': instance.meta,
      'auth': instance.auth,
    };

WGTAuth _$WGTAuthFromJson(Map<String, dynamic> json) => WGTAuth(
      emailAndPassword: json['emailAndPassword'],
      passkey: json['passkey'],
      google: json['google'],
      github: json['github'],
      apple: json['apple'],
      microsoft: json['microsoft'],
      sso: json['sso'],
      oidc: json['oidc'],
    );

Map<String, dynamic> _$WGTAuthToJson(WGTAuth instance) => <String, dynamic>{
      'emailAndPassword': instance.emailAndPassword,
      'passkey': instance.passkey,
      'google': instance.google,
      'github': instance.github,
      'apple': instance.apple,
      'microsoft': instance.microsoft,
      'sso': instance.sso,
      'oidc': instance.oidc,
    };

WGTStyle _$WGTStyleFromJson(Map<String, dynamic> json) => WGTStyle(
      colours:
          WGTStyleColours.fromJson(json['colours'] as Map<String, dynamic>),
      font: WGTStyleFont.fromJson(json['font']),
    );

Map<String, dynamic> _$WGTStyleToJson(WGTStyle instance) => <String, dynamic>{
      'colours': instance.colours,
      'font': instance.font,
    };

WGTMeta _$WGTMetaFromJson(Map<String, dynamic> json) => WGTMeta(
      title: json['title'] as String,
      description: json['description'] as String,
      keywords: json['keywords'] as String,
    );

Map<String, dynamic> _$WGTMetaToJson(WGTMeta instance) => <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'keywords': instance.keywords,
    };

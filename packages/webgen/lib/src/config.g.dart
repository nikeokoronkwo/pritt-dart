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
      icon: json['icon'] as String?,
      logo: json['logo'] as String?,
      assets: (json['assets'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      meta: json['meta'] == null
          ? null
          : WGTMeta.fromJson(json['meta'] as Map<String, dynamic>),
      auth: WGTAuth.fromJson(json['auth'] as Map<String, dynamic>),
      env: (json['env'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
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
      'env': instance.env,
    };

WGTAuth _$WGTAuthFromJson(Map<String, dynamic> json) => WGTAuth(
      magicLink: json['magic_link'] as bool,
      passkey: json['passkey'] as bool,
      google: json['google'] as bool? ?? false,
      github: json['github'] as bool? ?? false,
      sso: json['sso'],
      oidc: json['oidc'],
      oauth: (json['oauth'] as List<dynamic>?)
              ?.map((e) => WGTOAuth.fromJson(e as Map<String, dynamic>)) ??
          const [],
    );

Map<String, dynamic> _$WGTAuthToJson(WGTAuth instance) => <String, dynamic>{
      'magic_link': instance.magicLink,
      'passkey': instance.passkey,
      'google': instance.google,
      'github': instance.github,
      'sso': instance.sso,
      'oidc': instance.oidc,
      'oauth': instance.oauth.toList(),
    };

WGTOAuth _$WGTOAuthFromJson(Map<String, dynamic> json) => WGTOAuth();

Map<String, dynamic> _$WGTOAuthToJson(WGTOAuth instance) => <String, dynamic>{};

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
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WGTMetaToJson(WGTMeta instance) => <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'keywords': instance.keywords,
    };

import 'package:json_annotation/json_annotation.dart';

import 'config/style.dart';

part 'config.g.dart';

@JsonSerializable()
class WebGenTemplateConfig {
  final String name;

  final String? description;

  final String? catchLine;

  final WGTStyle style;

  final String? icon;

  final String? logo;

  final List<String> assets;

  final WGTMeta? meta;

  final WGTAuth auth;

  final Map<String, String>? env;

  const WebGenTemplateConfig(
      {required this.name,
      required this.style,
      this.icon,
      this.logo,
      this.assets = const [],
      this.meta,
      required this.auth,
      this.env});

  factory WebGenTemplateConfig.fromJson(Map<String, dynamic> json) =>
      _$WebGenTemplateConfigFromJson(json);
  Map<String, dynamic> toJson() => _$WebGenTemplateConfigToJson(this);
}

@JsonSerializable()
class WGTAuth {
  // bool emailAndPassword;
  @JsonKey(name: 'magic_link')
  bool magicLink;
  bool passkey;
  bool google;
  bool github;
  // bool apple;
  // bool microsoft;
  dynamic sso;
  dynamic oidc;
  Iterable<WGTOAuth> oauth;

  WGTAuth(
      {required this.magicLink,
      required this.passkey,
      this.google = false,
      this.github = false,
      this.sso,
      this.oidc,
      this.oauth = const []});

  factory WGTAuth.fromJson(Map<String, dynamic> json) =>
      _$WGTAuthFromJson(json);
  Map<String, dynamic> toJson() => _$WGTAuthToJson(this);
}

@JsonSerializable()
class WGTOAuth {
  WGTOAuth();

  factory WGTOAuth.fromJson(Map<String, dynamic> json) =>
      _$WGTOAuthFromJson(json);
  Map<String, dynamic> toJson() => _$WGTOAuthToJson(this);
}

@JsonSerializable()
class WGTStyle {
  static const defaultStyle = WGTStyle(
    colours: WGTStyleColours(
      primary: '#6200EE',
      secondary: '#03DAC6',
      background: '#FFFFFF',
      text: '#000000',
      accent: '#FF4081',
    ),
    font: WGTStyleFont.defaultFont,
  );

  final WGTStyleColours colours;
  final WGTStyleFont font;

  const WGTStyle({
    required this.colours,
    required this.font,
  });

  factory WGTStyle.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return _$WGTStyleFromJson(json);
    } else if (json is String) {
      // If the input is a string, assume it's a style name and return the default style
      return switch (json.toLowerCase()) {
        'default' => WGTStyle.defaultStyle,
        _ => throw ArgumentError('Invalid style type: $json'),
      };
    }
    // If the input is neither a Map nor a String, return the default style
    throw ArgumentError('Invalid JSON format: $json');
  }

  Map<String, dynamic> toJson() => _$WGTStyleToJson(this);
}

/// Metadata definitions used for SEO
@JsonSerializable()
class WGTMeta {
  final String title;
  final String description;
  final List<String> keywords;

  const WGTMeta({
    required this.title,
    required this.description,
    this.keywords = const [],
  });

  factory WGTMeta.fromJson(Map<String, dynamic> json) =>
      _$WGTMetaFromJson(json);
  Map<String, dynamic> toJson() => _$WGTMetaToJson(this);
}

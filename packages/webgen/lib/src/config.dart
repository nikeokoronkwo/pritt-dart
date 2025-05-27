import 'package:json_annotation/json_annotation.dart';

import 'config/style.dart';

@JsonSerializable()
class WebGenTemplateConfig {
  final String name;

  final WGTStyle style;

  final String icon;

  final String logo;

  final List<String> assets;

  final WGTMeta? meta;

  final WGTAuth auth;

  const WebGenTemplateConfig({
    required this.name,
    required this.style,
    required this.icon,
    required this.logo,
    required this.assets,
    this.meta,
    required this.auth,
  });
}

@JsonSerializable()
class WGTAuth {
  dynamic emailAndPassword;
  dynamic passkey;
  dynamic google;
  dynamic github;
  dynamic apple;
  dynamic microsoft;
  dynamic sso;
  dynamic oidc;
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
  final String keywords;
  
  const WGTMeta({
    required this.title,
    required this.description,
    required this.keywords,
  });

  factory WGTMeta.fromJson(Map<String, dynamic> json) => _$WGTMetaFromJson(json);
  Map<String, dynamic> toJson() => _$WGTMetaToJson(this);
}


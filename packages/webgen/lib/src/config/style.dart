import 'package:json_annotation/json_annotation.dart';

import '../js/gradient.dart';

part 'style.g.dart';

@JsonSerializable()
class WGTStyleColours {
  @JsonKey(fromJson: WGTCS.fromJson)
  final WGTColourSpectrum primary;

  final String? secondary;
  final String? background;
  final String? text;

  @JsonKey(fromJson: WGTCS.fromJson)
  final WGTColourSpectrum accent;

  const WGTStyleColours({
    required this.primary,
    this.secondary,
    this.background,
    this.text,
    required this.accent,
  });

  WGTStyleColours.gen({
    required String primary,
    this.secondary,
    this.background,
    this.text,
    required String accent,
  })  : primary = generateTailwindColorScale(primary),
        accent = generateTailwindColorScale(accent);

  factory WGTStyleColours.fromJson(Map<String, dynamic> json) =>
      _$WGTStyleColoursFromJson(json);
  Map<String, dynamic> toJson() => _$WGTStyleColoursToJson(this);
}

typedef WGTColourSpectrum = Map<int, String>;

extension WGTCS on WGTColourSpectrum {
  static WGTColourSpectrum fromJson(dynamic json) {
    if (json is String)
      return generateTailwindColorScale(json);
    else if (json is Map<int, String>)
      return json;
    else if (json is Map<dynamic, String>) {
      return json.map((k, v) {
        if (k is int)
          return MapEntry(k, v);
        else if (k is String) {
          if (k.toLowerCase() == 'default') return MapEntry(-1, v);
          if (int.tryParse(k) != null) {
            return MapEntry(int.parse(k), v);
          }
        }

        return MapEntry(1000 * 100 + k.hashCode, v);
      });
    } else
      throw Exception();
  }

  String get defaultColour =>
      this[-1] ?? this.values.toList()[this.length ~/ 2];
}

@JsonEnum(valueField: 'value')
enum FontType {
  sansSerif('sans-serif'),
  serif('serif');

  const FontType(this.value);

  final String value;
}

@JsonSerializable()
class WGTStyleFont {
  final String family;
  final int? size;
  final int? weight;
  final FontType type;

  // default sans ser
  static const defaultFont = WGTStyleFont(
    family: 'Manrope',
    size: 16,
    weight: 400,
  );
  static const serifFont = WGTStyleFont(
      family: 'Times New Roman', size: 16, weight: 400, type: FontType.serif);

  const WGTStyleFont(
      {required this.family,
      this.size,
      this.weight,
      this.type = FontType.sansSerif});

  factory WGTStyleFont.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return _$WGTStyleFontFromJson(json);
    } else if (json is String) {
      // If the input is a string, assume it's a font family and create a default font
      return switch (json.toLowerCase()) {
        'serif' => WGTStyleFont.serifFont,
        'sans-serif' => WGTStyleFont.defaultFont,
        _ => throw ArgumentError('Invalid font type: $json'),
      };
    }
    // If the input is neither a Map nor a String, return a default font
    throw ArgumentError('Invalid font format: $json');
  }
  Map<String, dynamic> toJson() => _$WGTStyleFontToJson(this);
}

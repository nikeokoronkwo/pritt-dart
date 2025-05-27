import 'package:json_annotation/json_annotation.dart';

part 'style.g.dart';

@JsonSerializable()
class WGTStyleColours {
  final String primary;
  final String? secondary;
  final String? background;
  final String? text;
  final String accent;

  const WGTStyleColours({
    required this.primary,
    this.secondary,
    this.background,
    this.text,
    required this.accent,
  });

  factory WGTStyleColours.fromJson(Map<String, dynamic> json) => _$WGTStyleColoursFromJson(json);
  Map<String, dynamic> toJson() => _$WGTStyleColoursToJson(this);
}

@JsonSerializable()
class WGTStyleFont {
  final String family;
  final int? size;
  final int? weight;

  // default sans ser
  static const defaultFont = WGTStyleFont(
    family: 'Arial',
    size: 16,
    weight: 400,
  );
  static const serifFont = WGTStyleFont(
    family: 'Times New Roman',
    size: 16,
    weight: 400,
  );

  const WGTStyleFont({
    required this.family,
    this.size,
    this.weight,
  });

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

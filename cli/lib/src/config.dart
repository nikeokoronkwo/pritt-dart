import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

/// The pritt configuration file, located at the root of the project.
/// This file is used to configure and provide information about the given package to Pritt.
/// 
/// The configuration file is a YAML file, and is used to configure the package.
@JsonSerializable()
class PrittConfig {
  PrittConfig();

  factory PrittConfig.fromJson(Map<String, dynamic> json) =>
      _$PrittConfigFromJson(json);
  Map<String, dynamic> toJson() => _$PrittConfigToJson(this);
}

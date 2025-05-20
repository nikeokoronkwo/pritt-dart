

import 'package:pritt_common/interface.dart';

/// A configuration object for a plugin
class Config {
  String name;
  Map<String, dynamic> rawConfig;

  String version;
  String? description;
  Author author;
  String license;

  Config({
    required this.name,
    required this.rawConfig,
    required this.version,
    this.description,
    required this.author,
    required this.license,
  });

  Config.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        rawConfig = json['config'] as Map<String, dynamic>,
        version = json['version'] as String,
        description = json['description'] as String?,
        author = Author.fromJson(json['author'] as Map<String, dynamic>),
        license = json['license'] as String;
}
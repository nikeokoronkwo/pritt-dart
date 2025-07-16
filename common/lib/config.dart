import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

/// The pritt configuration file, located at the root of the project.
/// This file is used to configure and provide information about the given package to Pritt.
///
/// The configuration file is a YAML file, and is used to configure the package.
@JsonSerializable()
class PrittConfig {
  /// Contributors to the given package
  ///
  /// Either specify this, or have an [AUTHORS]() file at the root of the project
  List<User>? contributors;

  /// Whether the given package is private or not
  bool? private;

  PrittConfig({this.contributors, this.private = false});

  factory PrittConfig.fromJson(Map<String, dynamic> json) =>
      _$PrittConfigFromJson(json);

  Map<String, dynamic> toJson() => _$PrittConfigToJson(this);
}

/// Represents a user in the Pritt configuration.
class User {
  String name;

  String? email;

  User({required this.name, this.email});

  factory User.parse(String entry) {
    final emailRegex = RegExp(r'<([^>]+)>');
    final emailMatch = emailRegex.firstMatch(entry);
    final name = emailMatch == null
        ? entry.trim()
        : entry.substring(0, emailMatch.start).trim();
    final email = emailMatch?.group(1)?.trim();

    return User(name: name, email: email);
  }

  factory User.fromJson(dynamic json) {
    if (json is String) {
      return User.parse(json);
    }
    return User(name: json['name'] as String, email: json['email'] as String?);
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (email != null) 'email': email,
  };
}

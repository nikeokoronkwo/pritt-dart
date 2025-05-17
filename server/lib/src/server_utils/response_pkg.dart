import 'package:json_annotation/json_annotation.dart';
import '../main/crs/db/schema.dart';

part 'response_pkg.g.dart';

/// The response object for /api/packages
@JsonSerializable()
class ResponsePkg {
  String name;
  String version;
  ResponsePkgUser author;
  String? language;

  @JsonKey(name: 'created_at')
  DateTime createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;

  ResponsePkg({
    required this.name,
    required this.version,
    required this.author,
    this.language,
    required this.createdAt,
    this.updatedAt,
  });

  factory ResponsePkg.fromPackage(Package pkg) {
    return ResponsePkg(
        name: pkg.name,
        version: pkg.version,
        author: ResponsePkgUser(name: pkg.author.name, email: pkg.author.email),
        language: pkg.language,
        createdAt: pkg.created,
        updatedAt: pkg.updated);
  }

  factory ResponsePkg.fromJson(Map<String, dynamic> json) =>
      _$ResponsePkgFromJson(json);
  Map<String, dynamic> toJson() => _$ResponsePkgToJson(this);
}

@JsonSerializable()
class ResponsePkgUser {
  String name;

  String email;

  ResponsePkgUser({required this.name, required this.email});

  factory ResponsePkgUser.fromJson(Map<String, dynamic> json) =>
      _$ResponsePkgUserFromJson(json);
  Map<String, dynamic> toJson() => _$ResponsePkgUserToJson(this);
}

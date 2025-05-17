import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_server/src/main/crs/db/schema.dart';

part 'response_pkgver.g.dart';

@JsonSerializable()
class ResponsePkgVer {
  String name;
  String version;
  DateTime createdAt;
  Map<String, dynamic> info;
  Map<String, dynamic> env;
  Map<String, dynamic> metadata;
  List<Signature> signatures;
  bool? deprecated;
  bool? yanked;

  ResponsePkgVer({
    required this.name,
    required this.version,
    required this.createdAt,
    required this.info,
    required this.env,
    required this.metadata,
    required this.signatures,
    this.deprecated,
    this.yanked,
  });
  factory ResponsePkgVer.fromPackageVersion(PackageVersions pkgVer,
      {bool allowYankedAndDeprecated = false}) {
    return ResponsePkgVer(
      name: pkgVer.package.name,
      version: pkgVer.version,
      createdAt: pkgVer.created,
      info: pkgVer.info,
      env: pkgVer.env,
      metadata: pkgVer.metadata,
      signatures: pkgVer.signatures,
      deprecated: allowYankedAndDeprecated ? pkgVer.isDeprecated : null,
      yanked: allowYankedAndDeprecated ? pkgVer.isYanked : null,
    );
  }

  factory ResponsePkgVer.fromJson(Map<String, dynamic> json) =>
      _$ResponsePkgVerFromJson(json);
  Map<String, dynamic> toJson() => _$ResponsePkgVerToJson(this);
}

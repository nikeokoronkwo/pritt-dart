import 'package:json_annotation/json_annotation.dart';
import '../../../utils/mixins.dart';
import 'pubspec.dart';

part 'result.g.dart';

/// The result of a dart meta (i.e [AdapterResolveType.meta]) request
@JsonSerializable(includeIfNull: false)
class DartMetaResult with JsonConvertible {
  /// the name of the package
  final String name;

  /// the latest version of the package
  final DartPackage latest;

  /// all the versions of the package
  final List<DartPackage> versions;

  const DartMetaResult({
    required this.name,
    required this.latest,
    required this.versions,
  });

  factory DartMetaResult.fromJson(Map<String, dynamic> json) =>
      _$DartMetaResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DartMetaResultToJson(this);
}

@JsonSerializable(includeIfNull: false)
class DartPackage {
  /// The version of the package
  final String version;

  /// pubspec.yaml, but in JSON format
  final PubSpec pubspec;

  /// The archive URL of the package'
  @JsonKey(name: 'archive_url')
  final String archiveUrl;

  /// The archive SHA256 hash of the file
  @JsonKey(name: 'archive_sha256')
  final String archiveHash;

  /// The date the package was published
  final DateTime published;

  const DartPackage({
    required this.version,
    required this.pubspec,
    required this.archiveUrl,
    required this.archiveHash,
    required this.published,
  });

  factory DartPackage.fromJson(Map<String, dynamic> json) =>
      _$DartPackageFromJson(json);
      
  Map<String, dynamic> toJson() => _$DartPackageToJson(this);
}

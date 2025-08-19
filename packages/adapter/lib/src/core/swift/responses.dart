import 'package:json_annotation/json_annotation.dart';

import '../../utils/mixins.dart';
import 'error.dart';

part 'responses.g.dart';

class SwiftPackageResponse with JsonConvertible {
  final Map<String, SwiftRelease> releases;

  SwiftPackageResponse({this.releases = const {}});

  @override
  Map<String, dynamic> toJson() =>
      releases.map((k, v) => MapEntry(k, v.toJson()));
}

@JsonSerializable()
class SwiftRelease with JsonConvertible {
  final Uri uri;
  final SwiftError? problem;

  const SwiftRelease({required this.uri, this.problem});

  factory SwiftRelease.fromJson(Map<String, dynamic> json) =>
      _$SwiftReleaseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SwiftReleaseToJson(this);
}

@JsonSerializable()
class SwiftPackage with JsonConvertible {
  final String id;
  final String version;
  final Map<String, dynamic> metadata;
  final List<SwiftResource> resources;
  final DateTime? publishedAt;

  const SwiftPackage({
    required this.id,
    required this.version,
    this.metadata = const {},
    required this.resources,
    this.publishedAt,
  });

  factory SwiftPackage.fromJson(Map<String, dynamic> json) =>
      _$SwiftPackageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SwiftPackageToJson(this);
}

@JsonSerializable()
class SwiftResource with JsonConvertible {
  @JsonKey(includeToJson: true)
  final String name = 'source-archive';

  @JsonKey(includeToJson: true)
  final String type = 'application/zip';

  final String checksum;

  const SwiftResource({required this.checksum});

  factory SwiftResource.fromJson(Map<String, dynamic> json) =>
      _$SwiftResourceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SwiftResourceToJson(this);
}

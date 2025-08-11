import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_common/version.dart';

import '../../utils/mixins.dart';
import 'error.dart';

part 'responses.g.dart';

class SwiftPackageResponse with JsonConvertible {
  final Map<String, SwiftRelease> releases;

  SwiftPackageResponse({
    this.releases = const {}
  });

  @override
  Map<String, dynamic> toJson() => 
    releases.map((k, v) => MapEntry(k, v.toJson()));
}

@JsonSerializable()
class SwiftRelease with JsonConvertible {
  final Uri uri;
  final SwiftError? problem;

  const SwiftRelease({
    required this.uri,
    this.problem
  });

  factory SwiftRelease.fromJson(Map<String, dynamic> json) 
    => _$SwiftReleaseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SwiftReleaseToJson(this);
}
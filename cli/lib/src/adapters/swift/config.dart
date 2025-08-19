// ignore_for_file: overridden_fields

import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_common/interface.dart';

import '../base/config.dart';

part 'config.g.dart';

// TODO(nikeokoronkwo): add support for dependencies.
@JsonSerializable()
final class PackageSwiftConfig extends Config {
  @override
  @JsonKey(includeToJson: false)
  final Author author;

  @override
  @JsonKey(includeToJson: false)
  final String version;

  final List<PackageSwiftPlatform> platforms;

  final List products;

  const PackageSwiftConfig({
    required super.name,
    required this.author,
    required this.version,
    required this.platforms,
    required this.products,
  }) : super(author: author, version: version);

  @override
  // TODO(nikeokoronkwo): implement configMetadata
  Map<String, dynamic> get configMetadata => throw UnimplementedError();

  @override
  Map<String, dynamic>? get rawConfig => {};

  factory PackageSwiftConfig.fromJson(
    Map<String, dynamic> json, {
    required Author author,
    required String version,
  }) => _$PackageSwiftConfigFromJson({
    ...json,
    'author': author.toJson(),
    'version': version,
  });

  Map<String, dynamic> toJson() => _$PackageSwiftConfigToJson(this);
}

@JsonSerializable()
class PackageSwiftPlatform {
  final List<dynamic> options;
  final String platformName;
  final String version;

  const PackageSwiftPlatform({
    required this.options,
    required this.platformName,
    required this.version,
  });

  factory PackageSwiftPlatform.fromJson(Map<String, dynamic> json) =>
      _$PackageSwiftPlatformFromJson(json);

  Map<String, dynamic> toJson() => _$PackageSwiftPlatformToJson(this);
}

@JsonSerializable()
class PackageSwiftProduct {
  final String name;
  final List<String> targets;
  final Map<String, dynamic> type;

  const PackageSwiftProduct({
    required this.name,
    this.type = const {},
    required this.targets,
  });

  factory PackageSwiftProduct.fromJson(Map<String, dynamic> json) =>
      _$PackageSwiftProductFromJson(json);

  Map<String, dynamic> toJson() => _$PackageSwiftProductToJson(this);
}

@JsonSerializable()
class PackageSwiftTarget {
  final String name;
  final String type;
  final List<String> exclude;
  final bool packageAccess;
  final List<String> resources;
  final List<dynamic> settings;
  final List<PackageSwiftTargetDependency> dependencies;

  const PackageSwiftTarget({
    required this.name,
    required this.type,
    required this.dependencies,
    this.exclude = const [],
    this.packageAccess = false,
    this.resources = const [],
    this.settings = const [],
  });

  factory PackageSwiftTarget.fromJson(Map<String, dynamic> json) =>
      _$PackageSwiftTargetFromJson(json);

  Map<String, dynamic> toJson() => _$PackageSwiftTargetToJson(this);
}

@JsonSerializable()
class PackageSwiftTargetDependency {
  final List<String?>? product;
  final List<String?>? byName;

  const PackageSwiftTargetDependency({
    required this.product,
    required this.byName,
  });

  factory PackageSwiftTargetDependency.fromJson(Map<String, dynamic> json) =>
      _$PackageSwiftTargetDependencyFromJson(json);

  Map<String, dynamic> toJson() => _$PackageSwiftTargetDependencyToJson(this);
}

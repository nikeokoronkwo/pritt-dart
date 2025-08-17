// ignore_for_file: overridden_fields

import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_common/interface.dart';

import '../base/config.dart';

part 'config.g.dart';

@JsonSerializable()
final class PackageSwiftConfig extends Config {
  @override
  @JsonKey(includeToJson: false)
  final Author author;

  @override
  @JsonKey(includeToJson: false)
  final String version;

  const PackageSwiftConfig({
    required super.name,
    required this.author,
    required this.version,
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

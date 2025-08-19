// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageSwiftConfig _$PackageSwiftConfigFromJson(Map<String, dynamic> json) =>
    PackageSwiftConfig(
      name: json['name'] as String,
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      version: json['version'] as String,
      platforms: (json['platforms'] as List<dynamic>)
          .map((e) => PackageSwiftPlatform.fromJson(e as Map<String, dynamic>))
          .toList(),
      products: json['products'] as List<dynamic>,
    );

Map<String, dynamic> _$PackageSwiftConfigToJson(PackageSwiftConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'platforms': instance.platforms,
      'products': instance.products,
    };

PackageSwiftPlatform _$PackageSwiftPlatformFromJson(
  Map<String, dynamic> json,
) => PackageSwiftPlatform(
  options: json['options'] as List<dynamic>,
  platformName: json['platformName'] as String,
  version: json['version'] as String,
);

Map<String, dynamic> _$PackageSwiftPlatformToJson(
  PackageSwiftPlatform instance,
) => <String, dynamic>{
  'options': instance.options,
  'platformName': instance.platformName,
  'version': instance.version,
};

PackageSwiftProduct _$PackageSwiftProductFromJson(Map<String, dynamic> json) =>
    PackageSwiftProduct(
      name: json['name'] as String,
      type: json['type'] as Map<String, dynamic>? ?? const {},
      targets: (json['targets'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PackageSwiftProductToJson(
  PackageSwiftProduct instance,
) => <String, dynamic>{
  'name': instance.name,
  'targets': instance.targets,
  'type': instance.type,
};

PackageSwiftTarget _$PackageSwiftTargetFromJson(
  Map<String, dynamic> json,
) => PackageSwiftTarget(
  name: json['name'] as String,
  type: json['type'] as String,
  dependencies: (json['dependencies'] as List<dynamic>)
      .map(
        (e) => PackageSwiftTargetDependency.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  exclude:
      (json['exclude'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  packageAccess: json['packageAccess'] as bool? ?? false,
  resources:
      (json['resources'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  settings: json['settings'] as List<dynamic>? ?? const [],
);

Map<String, dynamic> _$PackageSwiftTargetToJson(PackageSwiftTarget instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'exclude': instance.exclude,
      'packageAccess': instance.packageAccess,
      'resources': instance.resources,
      'settings': instance.settings,
      'dependencies': instance.dependencies,
    };

PackageSwiftTargetDependency _$PackageSwiftTargetDependencyFromJson(
  Map<String, dynamic> json,
) => PackageSwiftTargetDependency(
  product: (json['product'] as List<dynamic>?)
      ?.map((e) => e as String?)
      .toList(),
  byName: (json['byName'] as List<dynamic>?)?.map((e) => e as String?).toList(),
);

Map<String, dynamic> _$PackageSwiftTargetDependencyToJson(
  PackageSwiftTargetDependency instance,
) => <String, dynamic>{'product': instance.product, 'byName': instance.byName};

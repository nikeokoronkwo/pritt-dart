// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubspec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubSpec _$PubSpecFromJson(Map<String, dynamic> json) => PubSpec(
      dependencies: json['dependencies'] as Map<String, dynamic>?,
      dependencyOverrides:
          json['dependency_overrides'] as Map<String, dynamic>?,
      description: json['description'] as String?,
      devDependencies: json['dev_dependencies'] as Map<String, dynamic>?,
      documentation: json['documentation'] as String?,
      environment: Map<String, String>.from(json['environment'] as Map),
      executables: (json['executables'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String?),
      ),
      falseSecrets: json['false_secrets'] as List<dynamic>?,
      flutter: json['flutter'] == null
          ? null
          : Flutter.fromJson(json['flutter'] as Map<String, dynamic>),
      funding:
          (json['funding'] as List<dynamic>?)?.map((e) => e as String).toList(),
      homepage: json['homepage'] as String?,
      ignoredAdvisories: (json['ignored_advisories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      issueTracker: json['issue_tracker'] as String?,
      name: json['name'] as String,
      platforms: json['platforms'] == null
          ? null
          : Platforms.fromJson(json['platforms'] as Map<String, dynamic>),
      publishTo: json['publish_to'] as String?,
      repository: json['repository'] as String?,
      screenshots: (json['screenshots'] as List<dynamic>?)
          ?.map((e) => Screenshot.fromJson(e as Map<String, dynamic>))
          .toList(),
      topics:
          (json['topics'] as List<dynamic>?)?.map((e) => e as String).toList(),
      version: json['version'] as String?,
    );

Map<String, dynamic> _$PubSpecToJson(PubSpec instance) => <String, dynamic>{
      'dependencies': instance.dependencies,
      'dependency_overrides': instance.dependencyOverrides,
      'description': instance.description,
      'dev_dependencies': instance.devDependencies,
      'documentation': instance.documentation,
      'environment': instance.environment,
      'executables': instance.executables,
      'false_secrets': instance.falseSecrets,
      'flutter': instance.flutter,
      'funding': instance.funding,
      'homepage': instance.homepage,
      'ignored_advisories': instance.ignoredAdvisories,
      'issue_tracker': instance.issueTracker,
      'name': instance.name,
      'platforms': instance.platforms,
      'publish_to': instance.publishTo,
      'repository': instance.repository,
      'screenshots': instance.screenshots,
      'topics': instance.topics,
      'version': instance.version,
    };

Dependency _$DependencyFromJson(Map<String, dynamic> json) => Dependency(
      sdk: json['sdk'] as String?,
      version: json['version'] as String?,
      hosted: json['hosted'],
      git: json['git'],
      path: json['path'] as String?,
    );

Map<String, dynamic> _$DependencyToJson(Dependency instance) =>
    <String, dynamic>{
      'sdk': instance.sdk,
      'version': instance.version,
      'hosted': instance.hosted,
      'git': instance.git,
      'path': instance.path,
    };

GitClass _$GitClassFromJson(Map<String, dynamic> json) => GitClass(
      path: json['path'] as String?,
      ref: json['ref'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$GitClassToJson(GitClass instance) => <String, dynamic>{
      'path': instance.path,
      'ref': instance.ref,
      'url': instance.url,
    };

HostedClass _$HostedClassFromJson(Map<String, dynamic> json) => HostedClass(
      name: json['name'] as String?,
      url: json['url'] as String,
    );

Map<String, dynamic> _$HostedClassToJson(HostedClass instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
    };

Flutter _$FlutterFromJson(Map<String, dynamic> json) => Flutter(
      assets: json['assets'] as List<dynamic>?,
      fonts: (json['fonts'] as List<dynamic>?)
          ?.map((e) => Font.fromJson(e as Map<String, dynamic>))
          .toList(),
      generate: json['generate'] as bool?,
      shaders:
          (json['shaders'] as List<dynamic>?)?.map((e) => e as String).toList(),
      usesMaterialDesign: json['uses-material-design'] as bool?,
    );

Map<String, dynamic> _$FlutterToJson(Flutter instance) => <String, dynamic>{
      'assets': instance.assets,
      'fonts': instance.fonts,
      'generate': instance.generate,
      'shaders': instance.shaders,
      'uses-material-design': instance.usesMaterialDesign,
    };

AssetClass _$AssetClassFromJson(Map<String, dynamic> json) => AssetClass(
      flavors:
          (json['flavors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      path: json['path'] as String,
      transformers: (json['transformers'] as List<dynamic>?)
          ?.map((e) => AssetTransformer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AssetClassToJson(AssetClass instance) =>
    <String, dynamic>{
      'flavors': instance.flavors,
      'path': instance.path,
      'transformers': instance.transformers,
    };

AssetTransformer _$AssetTransformerFromJson(Map<String, dynamic> json) =>
    AssetTransformer(
      args: (json['args'] as List<dynamic>?)?.map((e) => e as String).toList(),
      package: json['package'] as String,
    );

Map<String, dynamic> _$AssetTransformerToJson(AssetTransformer instance) =>
    <String, dynamic>{
      'args': instance.args,
      'package': instance.package,
    };

Font _$FontFromJson(Map<String, dynamic> json) => Font(
      family: json['family'] as String,
      fonts: (json['fonts'] as List<dynamic>)
          .map((e) => FontFont.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FontToJson(Font instance) => <String, dynamic>{
      'family': instance.family,
      'fonts': instance.fonts,
    };

FontFont _$FontFontFromJson(Map<String, dynamic> json) => FontFont(
      asset: json['asset'] as String,
      style: $enumDecodeNullable(_$StyleEnumMap, json['style']),
      weight: (json['weight'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FontFontToJson(FontFont instance) => <String, dynamic>{
      'asset': instance.asset,
      'style': _$StyleEnumMap[instance.style],
      'weight': instance.weight,
    };

const _$StyleEnumMap = {
  Style.ITALIC: 'italic',
  Style.NORMAL: 'normal',
};

Platforms _$PlatformsFromJson(Map<String, dynamic> json) => Platforms(
      android: json['android'],
      ios: json['ios'],
      linux: json['linux'],
      macos: json['macos'],
      web: json['web'],
      windows: json['windows'],
    );

Map<String, dynamic> _$PlatformsToJson(Platforms instance) => <String, dynamic>{
      'android': instance.android,
      'ios': instance.ios,
      'linux': instance.linux,
      'macos': instance.macos,
      'web': instance.web,
      'windows': instance.windows,
    };

Screenshot _$ScreenshotFromJson(Map<String, dynamic> json) => Screenshot(
      description: json['description'] as String,
      path: json['path'] as String,
    );

Map<String, dynamic> _$ScreenshotToJson(Screenshot instance) =>
    <String, dynamic>{
      'description': instance.description,
      'path': instance.path,
    };

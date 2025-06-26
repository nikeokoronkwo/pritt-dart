// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubspec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubSpec _$PubSpecFromJson(Map json) => PubSpec(
      dependencies: (json['dependencies'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      dependencyOverrides: (json['dependency_overrides'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      description: json['description'] as String?,
      devDependencies: (json['dev_dependencies'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      documentation: json['documentation'] as String?,
      environment: Map<String, String>.from(json['environment'] as Map),
      executables: (json['executables'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String?),
      ),
      falseSecrets: json['false_secrets'] as List<dynamic>?,
      flutter: json['flutter'] == null
          ? null
          : Flutter.fromJson(Map<String, dynamic>.from(json['flutter'] as Map)),
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
          : Platforms.fromJson(
              Map<String, dynamic>.from(json['platforms'] as Map)),
      publishTo: json['publish_to'] as String?,
      repository: json['repository'] as String?,
      screenshots: (json['screenshots'] as List<dynamic>?)
          ?.map((e) => Screenshot.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      topics:
          (json['topics'] as List<dynamic>?)?.map((e) => e as String).toList(),
      version: json['version'] as String?,
    );

Map<String, dynamic> _$PubSpecToJson(PubSpec instance) => <String, dynamic>{
      if (instance.dependencies case final value?) 'dependencies': value,
      if (instance.dependencyOverrides case final value?)
        'dependency_overrides': value,
      if (instance.description case final value?) 'description': value,
      if (instance.devDependencies case final value?) 'dev_dependencies': value,
      if (instance.documentation case final value?) 'documentation': value,
      'environment': instance.environment,
      if (instance.executables case final value?) 'executables': value,
      if (instance.falseSecrets case final value?) 'false_secrets': value,
      if (instance.flutter?.toJson() case final value?) 'flutter': value,
      if (instance.funding case final value?) 'funding': value,
      if (instance.homepage case final value?) 'homepage': value,
      if (instance.ignoredAdvisories case final value?)
        'ignored_advisories': value,
      if (instance.issueTracker case final value?) 'issue_tracker': value,
      'name': instance.name,
      if (instance.platforms?.toJson() case final value?) 'platforms': value,
      if (instance.publishTo case final value?) 'publish_to': value,
      if (instance.repository case final value?) 'repository': value,
      if (instance.screenshots?.map((e) => e.toJson()).toList()
          case final value?)
        'screenshots': value,
      if (instance.topics case final value?) 'topics': value,
      if (instance.version case final value?) 'version': value,
    };

Dependency _$DependencyFromJson(Map json) => Dependency(
      sdk: json['sdk'] as String?,
      version: json['version'] as String?,
      hosted: json['hosted'],
      git: json['git'],
      path: json['path'] as String?,
    );

Map<String, dynamic> _$DependencyToJson(Dependency instance) =>
    <String, dynamic>{
      if (instance.sdk case final value?) 'sdk': value,
      if (instance.version case final value?) 'version': value,
      if (instance.hosted case final value?) 'hosted': value,
      if (instance.git case final value?) 'git': value,
      if (instance.path case final value?) 'path': value,
    };

GitClass _$GitClassFromJson(Map json) => GitClass(
      path: json['path'] as String?,
      ref: json['ref'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$GitClassToJson(GitClass instance) => <String, dynamic>{
      if (instance.path case final value?) 'path': value,
      if (instance.ref case final value?) 'ref': value,
      if (instance.url case final value?) 'url': value,
    };

HostedClass _$HostedClassFromJson(Map json) => HostedClass(
      name: json['name'] as String?,
      url: json['url'] as String,
    );

Map<String, dynamic> _$HostedClassToJson(HostedClass instance) =>
    <String, dynamic>{
      if (instance.name case final value?) 'name': value,
      'url': instance.url,
    };

Flutter _$FlutterFromJson(Map json) => Flutter(
      assets: json['assets'] as List<dynamic>?,
      fonts: (json['fonts'] as List<dynamic>?)
          ?.map((e) => Font.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      generate: json['generate'] as bool?,
      shaders:
          (json['shaders'] as List<dynamic>?)?.map((e) => e as String).toList(),
      usesMaterialDesign: json['uses-material-design'] as bool?,
    );

Map<String, dynamic> _$FlutterToJson(Flutter instance) => <String, dynamic>{
      if (instance.assets case final value?) 'assets': value,
      if (instance.fonts?.map((e) => e.toJson()).toList() case final value?)
        'fonts': value,
      if (instance.generate case final value?) 'generate': value,
      if (instance.shaders case final value?) 'shaders': value,
      if (instance.usesMaterialDesign case final value?)
        'uses-material-design': value,
    };

AssetClass _$AssetClassFromJson(Map json) => AssetClass(
      flavors:
          (json['flavors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      path: json['path'] as String,
      transformers: (json['transformers'] as List<dynamic>?)
          ?.map((e) =>
              AssetTransformer.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$AssetClassToJson(AssetClass instance) =>
    <String, dynamic>{
      if (instance.flavors case final value?) 'flavors': value,
      'path': instance.path,
      if (instance.transformers?.map((e) => e.toJson()).toList()
          case final value?)
        'transformers': value,
    };

AssetTransformer _$AssetTransformerFromJson(Map json) => AssetTransformer(
      args: (json['args'] as List<dynamic>?)?.map((e) => e as String).toList(),
      package: json['package'] as String,
    );

Map<String, dynamic> _$AssetTransformerToJson(AssetTransformer instance) =>
    <String, dynamic>{
      if (instance.args case final value?) 'args': value,
      'package': instance.package,
    };

Font _$FontFromJson(Map json) => Font(
      family: json['family'] as String,
      fonts: (json['fonts'] as List<dynamic>)
          .map((e) => FontFont.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$FontToJson(Font instance) => <String, dynamic>{
      'family': instance.family,
      'fonts': instance.fonts.map((e) => e.toJson()).toList(),
    };

FontFont _$FontFontFromJson(Map json) => FontFont(
      asset: json['asset'] as String,
      style: $enumDecodeNullable(_$StyleEnumMap, json['style']),
      weight: (json['weight'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FontFontToJson(FontFont instance) => <String, dynamic>{
      'asset': instance.asset,
      if (_$StyleEnumMap[instance.style] case final value?) 'style': value,
      if (instance.weight case final value?) 'weight': value,
    };

const _$StyleEnumMap = {
  Style.ITALIC: 'italic',
  Style.NORMAL: 'normal',
};

Platforms _$PlatformsFromJson(Map json) => Platforms(
      android: json['android'],
      ios: json['ios'],
      linux: json['linux'],
      macos: json['macos'],
      web: json['web'],
      windows: json['windows'],
    );

Map<String, dynamic> _$PlatformsToJson(Platforms instance) => <String, dynamic>{
      if (instance.android case final value?) 'android': value,
      if (instance.ios case final value?) 'ios': value,
      if (instance.linux case final value?) 'linux': value,
      if (instance.macos case final value?) 'macos': value,
      if (instance.web case final value?) 'web': value,
      if (instance.windows case final value?) 'windows': value,
    };

Screenshot _$ScreenshotFromJson(Map json) => Screenshot(
      description: json['description'] as String,
      path: json['path'] as String,
    );

Map<String, dynamic> _$ScreenshotToJson(Screenshot instance) =>
    <String, dynamic>{
      'description': instance.description,
      'path': instance.path,
    };

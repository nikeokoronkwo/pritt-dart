// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'pubspec.g.dart';

///Dart Pubspec file
@JsonSerializable(includeIfNull: false)
class PubSpec {
  @JsonKey(name: "dependencies")
  final Map<String, dynamic>? dependencies;
  @JsonKey(name: "dependency_overrides")
  final Map<String, dynamic>? dependencyOverrides;

  ///A short, plain text sales-pitch for your package in English. [Learn
  ///More](https://dart.dev/tools/pub/pubspec#description)
  @JsonKey(name: "description")
  final String? description;
  @JsonKey(name: "dev_dependencies")
  final Map<String, dynamic>? devDependencies;

  ///A site that hosts documentation, separate from the main homepage and from the
  ///Pub-generated API reference. [Learn
  ///more](https://dart.dev/tools/pub/pubspec#documentation)
  @JsonKey(name: "documentation")
  final String? documentation;
  @JsonKey(name: "environment")
  final Map<String, String> environment;

  ///A package may expose one or more of its scripts as executables that can be run directly
  ///from the command line. [Learn more](https://dart.dev/tools/pub/pubspec#executables)
  @JsonKey(name: "executables")
  final Map<String, String?>? executables;

  ///Gitignore style list of files where pub will not search for accidentally exposed keys.
  ///[Learn more.](https://dart.dev/tools/pub/pubspec#false_secrets)
  @JsonKey(name: "false_secrets")
  final List<dynamic>? falseSecrets;

  ///Flutter-specific metadata. [Learn more.](https://docs.flutter.dev/tools/pubspec)
  @JsonKey(name: "flutter")
  final Flutter? flutter;

  ///List of URLs where users can sponsor development of the package. [Learn
  ///more.](https://dart.dev/tools/pub/pubspec#funding)
  @JsonKey(name: "funding")
  final List<String>? funding;

  ///A URL pointing to the website for your package. [Learn
  ///more](https://dart.dev/tools/pub/pubspec#homepage)
  @JsonKey(name: "homepage")
  final String? homepage;

  ///A list of security advisory identifiers that are ignored for this package. [See pub.dev
  ///Security Advisories](https://dart.dev/tools/pub/security-advisories) [Learn
  ///more.](https://dart.dev/tools/pub/pubspec#ignored_advisories)
  @JsonKey(name: "ignored_advisories")
  final List<String>? ignoredAdvisories;

  ///A URL for the package's issue tracker, where existing bugs can be viewed and new bugs can
  ///be filed. [Learn more](https://dart.dev/tools/pub/pubspec#issue_tracker)
  @JsonKey(name: "issue_tracker")
  final String? issueTracker;

  ///The name of this package. The name is how other packages refer to yours, should you
  ///publish it. [Learn more](https://dart.dev/tools/pub/pubspec#name)
  @JsonKey(name: "name")
  final String name;

  ///The platforms field specifies which platforms the package supports. [Learn
  ///more](https://dart.dev/tools/pub/pubspec#platforms)
  @JsonKey(name: "platforms")
  final Platforms? platforms;

  ///Can be used to specify a custom pub package server to publish. Specify none to prevent a
  ///package from being published. [Learn more.](https://dart.dev/tools/pub/pubspec#publish_to)
  @JsonKey(name: "publish_to")
  final String? publishTo;

  ///The optional repository field should contain the URL for your package's source code
  ///repository. [Learn more](https://dart.dev/tools/pub/pubspec#repository)
  @JsonKey(name: "repository")
  final String? repository;

  ///Showcase widgets or other visual elements using screenshots displayed that will be
  ///displayed on pub.dev. [Learn more.](https://dart.dev/tools/pub/pubspec#screenshots)
  @JsonKey(name: "screenshots")
  final List<Screenshot>? screenshots;

  ///Pub.dev displays the topics on the package page as well as in the search results. [See
  ///the list of available topics](https://pub.dev/topics) [Learn
  ///more.](https://dart.dev/tools/pub/pubspec#topics)
  @JsonKey(name: "topics")
  final List<String>? topics;

  ///A version number is required to host your package on the pub.dev site, but can be omitted
  ///for local-only packages. If you omit it, your package is implicitly versioned 0.0.0.
  ///[Learn more](https://dart.dev/tools/pub/pubspec#version)
  @JsonKey(name: "version")
  final String? version;

  PubSpec({
    this.dependencies,
    this.dependencyOverrides,
    this.description,
    this.devDependencies,
    this.documentation,
    required this.environment,
    this.executables,
    this.falseSecrets,
    this.flutter,
    this.funding,
    this.homepage,
    this.ignoredAdvisories,
    this.issueTracker,
    required this.name,
    this.platforms,
    this.publishTo,
    this.repository,
    this.screenshots,
    this.topics,
    this.version,
  })  : assert(environment['sdk'] != null, "Environment SDK is required"),
        assert(name.isNotEmpty, "Name is required"),
        assert(version != null || publishTo == null,
            "Version is required if publishTo is not null");

  factory PubSpec.fromJson(Map<String, dynamic> json) =>
      _$PubSpecFromJson(json);

  Map<String, dynamic> toJson() => _$PubSpecToJson(this);
}

///Git dependency
///
///Path dependency
@JsonSerializable(includeIfNull: false)
class Dependency {
  ///The SDK which contains this package
  @JsonKey(name: "sdk")
  final String? sdk;
  @JsonKey(name: "version")
  final String? version;
  @JsonKey(name: "hosted")
  final dynamic hosted;
  @JsonKey(name: "git")
  final dynamic git;
  @JsonKey(name: "path")
  final String? path;

  Dependency({
    this.sdk,
    this.version,
    this.hosted,
    this.git,
    this.path,
  });

  factory Dependency.fromJson(Map<String, dynamic> json) =>
      _$DependencyFromJson(json);

  Map<String, dynamic> toJson() => _$DependencyToJson(this);
}

@JsonSerializable(includeIfNull: false)
class GitClass {
  ///Path of this package relative to the Git repo's root
  @JsonKey(name: "path")
  final String? path;

  ///The branch, tag, or anything else Git allows to identify a commit.
  @JsonKey(name: "ref")
  final String? ref;

  ///URI of the repository hosting this package
  @JsonKey(name: "url")
  final String? url;

  GitClass({
    this.path,
    this.ref,
    this.url,
  });

  factory GitClass.fromJson(Map<String, dynamic> json) =>
      _$GitClassFromJson(json);

  Map<String, dynamic> toJson() => _$GitClassToJson(this);
}

@JsonSerializable(includeIfNull: false)
class HostedClass {
  @JsonKey(name: "name")
  final String? name;

  ///The package server hosting this package
  @JsonKey(name: "url")
  final String url;

  HostedClass({
    this.name,
    required this.url,
  });

  factory HostedClass.fromJson(Map<String, dynamic> json) =>
      _$HostedClassFromJson(json);

  Map<String, dynamic> toJson() => _$HostedClassToJson(this);
}

///Flutter-specific metadata. [Learn more.](https://docs.flutter.dev/tools/pubspec)
@JsonSerializable(includeIfNull: false)
class Flutter {
  ///A list of directories or files that contain images or other assets. [Learn
  ///more.](https://flutter.dev/docs/development/ui/assets-and-images)
  @JsonKey(name: "assets")
  final List<dynamic>? assets;

  ///A list of font families and their fonts. [Learn
  ///more.](https://docs.flutter.dev/cookbook/design/fonts#declare-the-font-in-the-pubspec-yaml-file)
  @JsonKey(name: "fonts")
  final List<Font>? fonts;

  ///Enables generation of localized strings from arb files
  @JsonKey(name: "generate")
  final bool? generate;

  ///Shaders, in the form of GLSL files with the .frag extension. The Flutter command-line
  ///tool compiles the shader to its appropriate backend format, and generates its necessary
  ///runtime metadata. The compiled shader is then included in the application just like an
  ///asset. [Learn
  ///more](https://docs.flutter.dev/ui/design/graphics/fragment-shaders#adding-shaders-to-an-application)
  @JsonKey(name: "shaders")
  final List<String>? shaders;

  ///Whether this project uses the Material Design package. Required if you use the Material
  ///icon font
  @JsonKey(name: "uses-material-design")
  final bool? usesMaterialDesign;

  Flutter({
    this.assets,
    this.fonts,
    this.generate,
    this.shaders,
    this.usesMaterialDesign,
  });

  factory Flutter.fromJson(Map<String, dynamic> json) =>
      _$FlutterFromJson(json);

  Map<String, dynamic> toJson() => _$FlutterToJson(this);
}

@JsonSerializable(includeIfNull: false)
class AssetClass {
  ///A list of flavors that include the asset. [Learn
  ///more.](https://docs.flutter.dev/deployment/flavors#conditionally-bundling-assets-based-on-flavor)
  @JsonKey(name: "flavors")
  final List<String>? flavors;
  @JsonKey(name: "path")
  final String path;

  ///A list of transformers to apply to the asset. [Learn
  ///more.](https://docs.flutter.dev/ui/assets/asset-transformation)
  @JsonKey(name: "transformers")
  final List<AssetTransformer>? transformers;

  AssetClass({
    this.flavors,
    required this.path,
    this.transformers,
  });

  factory AssetClass.fromJson(Map<String, dynamic> json) =>
      _$AssetClassFromJson(json);

  Map<String, dynamic> toJson() => _$AssetClassToJson(this);
}

@JsonSerializable(includeIfNull: false)
class AssetTransformer {
  @JsonKey(name: "args")
  final List<String>? args;

  ///A Dart command-line app that is invoked with dart run with at least two arguments:
  ///--input, which contains the path to the file to transform and --output, which is the
  ///location where the transformer code must write its output to
  @JsonKey(name: "package")
  final String package;

  AssetTransformer({
    this.args,
    required this.package,
  });

  factory AssetTransformer.fromJson(Map<String, dynamic> json) =>
      _$AssetTransformerFromJson(json);

  Map<String, dynamic> toJson() => _$AssetTransformerToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Font {
  ///The name of the typeface. You use this name in the `fontFamily` property of a `TextStyle`
  ///object.
  @JsonKey(name: "family")
  final String family;
  @JsonKey(name: "fonts")
  final List<FontFont> fonts;

  Font({
    required this.family,
    required this.fonts,
  });

  factory Font.fromJson(Map<String, dynamic> json) => _$FontFromJson(json);

  Map<String, dynamic> toJson() => _$FontToJson(this);
}

@JsonSerializable(includeIfNull: false)
class FontFont {
  ///The path to the font file. Flutter supports the following font formats: OpenType font
  ///collections: .ttc, TrueType fonts: .ttf, OpenType fonts: .otf. Flutter does not support
  ///fonts in the Web Open Font Format, .woff and .woff2, on desktop platforms.
  @JsonKey(name: "asset")
  final String asset;

  ///The style property specifies whether the glyphs in the font file display as either italic
  ///or normal. These values correspond to the FontStyle. You can use these styles in the
  ///fontStyle property of a TextStyle object. [Learn
  ///more.](https://docs.flutter.dev/cookbook/design/fonts#set-font-weight)
  @JsonKey(name: "style")
  final Style? style;

  ///The weight property specifies the weight of the outlines in the file. These values
  ///correspond to the FontWeight and can be used in the fontWeight property of a TextStyle
  ///object. You can't use the weight property to override the weight of the font. [Learn
  ///more.](https://docs.flutter.dev/cookbook/design/fonts#specify-the-font-weight)
  @JsonKey(name: "weight")
  final int? weight;

  FontFont({
    required this.asset,
    this.style,
    this.weight,
  });

  factory FontFont.fromJson(Map<String, dynamic> json) =>
      _$FontFontFromJson(json);

  Map<String, dynamic> toJson() => _$FontFontToJson(this);
}

///The style property specifies whether the glyphs in the font file display as either italic
///or normal. These values correspond to the FontStyle. You can use these styles in the
///fontStyle property of a TextStyle object. [Learn
///more.](https://docs.flutter.dev/cookbook/design/fonts#set-font-weight)
enum Style {
  @JsonValue("italic")
  ITALIC,
  @JsonValue("normal")
  NORMAL
}

///The platforms field specifies which platforms the package supports. [Learn
///more](https://dart.dev/tools/pub/pubspec#platforms)
@JsonSerializable(includeIfNull: false)
class Platforms {
  @JsonKey(name: "android")
  final dynamic android;
  @JsonKey(name: "ios")
  final dynamic ios;
  @JsonKey(name: "linux")
  final dynamic linux;
  @JsonKey(name: "macos")
  final dynamic macos;
  @JsonKey(name: "web")
  final dynamic web;
  @JsonKey(name: "windows")
  final dynamic windows;

  Platforms({
    this.android,
    this.ios,
    this.linux,
    this.macos,
    this.web,
    this.windows,
  });

  factory Platforms.fromJson(Map<String, dynamic> json) =>
      _$PlatformsFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformsToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Screenshot {
  @JsonKey(name: "description")
  final String description;
  @JsonKey(name: "path")
  final String path;

  Screenshot({
    required this.description,
    required this.path,
  });

  factory Screenshot.fromJson(Map<String, dynamic> json) =>
      _$ScreenshotFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenshotToJson(this);
}

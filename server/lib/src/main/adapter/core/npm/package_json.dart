import 'package:json_annotation/json_annotation.dart';

part 'package_json.g.dart';

/// A package.json file is a JSON file that contains metadata about the package.
/// It is used by npm to manage the package and its dependencies.
@JsonSerializable()
class PackageJson {
  /// The name of the package
  final String name;

  /// The version of the package
  final String version;

  /// The description of the package
  final String? description;

  /// The keywords of the package
  final List<String>? keywords;

  /// The homepage of the package
  @JsonKey(name: 'homepage')
  final String? homePage;

  /// The bugs of the package
  final Map<String, String>? bugs;

  /// The license of the package
  final String? license;

  /// The author information of the package
  final dynamic author;

  /// Funding information of the package
  final dynamic funding;

  /// Contributors of the package
  final List<dynamic>? contributors;

  /// The repository of the package
  final dynamic repository;

  /// The files to be included in the package
  final List<String>? files;

  /// The exports of the package
  final Map<String, String>? exports;

  /// The dependencies of the package
  final Map<String, String>? dependencies;

  /// The main file of the package
  final String? main;

  /// The browser field of the package
  final String? browser;

  /// The bin field of the package
  final Map<String, String>? bin;

  /// The directories field of the package
  final PackageJsonDirectories? directories;

  /// scripts to be run before and after the package is installed
  final Map<String, String>? scripts;

  /// config
  final Map<String, dynamic>? config;

  /// dev dependencies of the project
  final Map<String, String>? devDependencies;

  /// peer dependencies of the project
  final Map<String, String>? peerDependencies;

  /// optional dependencies of the project
  final Map<String, String>? optionalDependencies;

  /// bundled dependencies of the project
  final Map<String, String>? bundledDependencies;

  /// engines
  final Map<String, String>? engines;

  /// os
  final List<String>? os;

  /// cpu
  final List<String>? cpu;

  /// libc
  final String? libc;

  /// whether the package is private or not
  final bool? private;

  /// The readme file of the package
  @JsonKey(name: 'readme')
  final String? readme;

  /// The readme file of the package
  @JsonKey(name: 'readmeFilename')
  final String? readmeFilename;

  const PackageJson({
    required this.name,
    required this.version,
    this.description,
    this.keywords,
    this.homePage,
    this.bugs,
    this.license,
    this.author,
    this.funding,
    this.contributors,
    this.repository,
    this.files,
    this.exports,
    this.dependencies,
    this.main,
    this.browser,
    this.bin,
    this.directories,
    this.scripts,
    this.config,
    this.devDependencies,
    this.peerDependencies,
    this.optionalDependencies,
    this.bundledDependencies,
    this.engines,
    this.os,
    this.cpu,
    this.libc,
    this.private = false,
    this.readme,
    this.readmeFilename,
  })  : assert(
            author is PackageJsonAuthor? ||
                author is String? ||
                author is Map<String, String>?,
            'author must be a PackageJsonAuthor, String or Map<String, String>'),
        assert(
            funding is PackageJsonFunding? ||
                funding is String? ||
                funding is Map<String, String>?,
            'funding must be a PackageJsonFunding, String or Map<String, String>'),
        assert(contributors == null || contributors is List<PackageJsonAuthor?>,
            'contributors must be a List<PackageJsonAuthor>'),
        assert(
            repository is PackageJsonRepository? ||
                repository is String? ||
                repository is Map<String, String>?,
            'repository must be a PackageJsonRepository, String or Map<String, String>');

  factory PackageJson.fromJson(Map<String, dynamic> json) =>
      _$PackageJsonFromJson(json);

  Map<String, dynamic> toJson() => _$PackageJsonToJson(this);
}

@JsonSerializable()
class PackageJsonDirectories {
  /// man pages
  final String? man;

  /// The directory of the lib
  final String? lib;

  /// doc
  final String? doc;

  const PackageJsonDirectories({
    this.man,
    this.lib,
    this.doc,
  });

  factory PackageJsonDirectories.fromJson(Map<String, dynamic> json) =>
      _$PackageJsonDirectoriesFromJson(json);

  Map<String, dynamic> toJson() => _$PackageJsonDirectoriesToJson(this);
}

@JsonSerializable()
class PackageJsonFunding {
  /// The type of funding
  final String? type;

  /// The url of the funding
  final String? url;

  const PackageJsonFunding({
    this.type,
    this.url,
  });

  factory PackageJsonFunding.fromJson(Map<String, dynamic> json) =>
      _$PackageJsonFundingFromJson(json);

  Map<String, dynamic> toJson() => _$PackageJsonFundingToJson(this);
}

@JsonSerializable()
class PackageJsonAuthor {
  /// The name of the author
  final String? name;

  /// The email of the author
  final String? email;

  /// The url of the author
  final String? url;

  const PackageJsonAuthor({
    this.name,
    this.email,
    this.url,
  });

  factory PackageJsonAuthor.fromJson(Map<String, dynamic> json) =>
      _$PackageJsonAuthorFromJson(json);

  Map<String, dynamic> toJson() => _$PackageJsonAuthorToJson(this);
}

@JsonSerializable()
class PackageJsonRepository {
  /// The type of the repository
  final String? type;

  /// The url of the repository
  final String? url;

  const PackageJsonRepository({
    this.type,
    this.url,
  });

  factory PackageJsonRepository.fromJson(Map<String, dynamic> json) =>
      _$PackageJsonRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$PackageJsonRepositoryToJson(this);
}

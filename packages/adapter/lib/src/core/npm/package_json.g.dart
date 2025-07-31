// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageJson _$PackageJsonFromJson(Map<String, dynamic> json) => PackageJson(
  name: json['name'] as String,
  version: json['version'] as String,
  description: json['description'] as String?,
  keywords: (json['keywords'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  homePage: json['homepage'] as String?,
  bugs: (json['bugs'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  license: json['license'] as String?,
  author: json['author'],
  funding: json['funding'],
  contributors: json['contributors'] as List<dynamic>?,
  repository: json['repository'],
  files: (json['files'] as List<dynamic>?)?.map((e) => e as String).toList(),
  exports: (json['exports'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  dependencies: (json['dependencies'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  main: json['main'] as String?,
  browser: json['browser'] as String?,
  bin: (json['bin'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  directories: json['directories'] == null
      ? null
      : PackageJsonDirectories.fromJson(
          json['directories'] as Map<String, dynamic>,
        ),
  scripts: (json['scripts'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  config: json['config'] as Map<String, dynamic>?,
  devDependencies: (json['devDependencies'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  peerDependencies: (json['peerDependencies'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  optionalDependencies: (json['optionalDependencies'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, e as String)),
  bundledDependencies: (json['bundledDependencies'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, e as String)),
  engines: (json['engines'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  os: (json['os'] as List<dynamic>?)?.map((e) => e as String).toList(),
  cpu: (json['cpu'] as List<dynamic>?)?.map((e) => e as String).toList(),
  libc: json['libc'] as String?,
  private: json['private'] as bool? ?? false,
  readme: json['readme'] as String?,
  readmeFilename: json['readmeFilename'] as String?,
);

Map<String, dynamic> _$PackageJsonToJson(PackageJson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'description': ?instance.description,
      'keywords': ?instance.keywords,
      'homepage': ?instance.homePage,
      'bugs': ?instance.bugs,
      'license': ?instance.license,
      'author': ?instance.author,
      'funding': ?instance.funding,
      'contributors': ?instance.contributors,
      'repository': ?instance.repository,
      'files': ?instance.files,
      'exports': ?instance.exports,
      'dependencies': ?instance.dependencies,
      'main': ?instance.main,
      'browser': ?instance.browser,
      'bin': ?instance.bin,
      'directories': ?instance.directories,
      'scripts': ?instance.scripts,
      'config': ?instance.config,
      'devDependencies': ?instance.devDependencies,
      'peerDependencies': ?instance.peerDependencies,
      'optionalDependencies': ?instance.optionalDependencies,
      'bundledDependencies': ?instance.bundledDependencies,
      'engines': ?instance.engines,
      'os': ?instance.os,
      'cpu': ?instance.cpu,
      'libc': ?instance.libc,
      'private': ?instance.private,
      'readme': ?instance.readme,
      'readmeFilename': ?instance.readmeFilename,
    };

PackageJsonDirectories _$PackageJsonDirectoriesFromJson(
  Map<String, dynamic> json,
) => PackageJsonDirectories(
  man: json['man'] as String?,
  lib: json['lib'] as String?,
  doc: json['doc'] as String?,
);

Map<String, dynamic> _$PackageJsonDirectoriesToJson(
  PackageJsonDirectories instance,
) => <String, dynamic>{
  'man': ?instance.man,
  'lib': ?instance.lib,
  'doc': ?instance.doc,
};

PackageJsonFunding _$PackageJsonFundingFromJson(Map<String, dynamic> json) =>
    PackageJsonFunding(
      type: json['type'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$PackageJsonFundingToJson(PackageJsonFunding instance) =>
    <String, dynamic>{'type': ?instance.type, 'url': ?instance.url};

PackageJsonAuthor _$PackageJsonAuthorFromJson(Map<String, dynamic> json) =>
    PackageJsonAuthor(
      name: json['name'] as String?,
      email: json['email'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$PackageJsonAuthorToJson(PackageJsonAuthor instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'email': ?instance.email,
      'url': ?instance.url,
    };

PackageJsonRepository _$PackageJsonRepositoryFromJson(
  Map<String, dynamic> json,
) => PackageJsonRepository(
  type: json['type'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$PackageJsonRepositoryToJson(
  PackageJsonRepository instance,
) => <String, dynamic>{'type': ?instance.type, 'url': ?instance.url};

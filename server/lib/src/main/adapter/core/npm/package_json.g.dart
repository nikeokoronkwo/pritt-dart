// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageJson _$PackageJsonFromJson(Map json) => PackageJson(
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String?,
      keywords: (json['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      homePage: json['homepage'] as String?,
      bugs: (json['bugs'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      license: json['license'] as String?,
      author: json['author'],
      funding: json['funding'],
      contributors: json['contributors'] as List<dynamic>?,
      repository: json['repository'],
      files:
          (json['files'] as List<dynamic>?)?.map((e) => e as String).toList(),
      exports: (json['exports'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      dependencies: (json['dependencies'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      main: json['main'] as String?,
      browser: json['browser'] as String?,
      bin: (json['bin'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      directories: json['directories'] == null
          ? null
          : PackageJsonDirectories.fromJson(
              Map<String, dynamic>.from(json['directories'] as Map)),
      scripts: (json['scripts'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      config: (json['config'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      devDependencies: (json['devDependencies'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      peerDependencies: (json['peerDependencies'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      optionalDependencies: (json['optionalDependencies'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      bundledDependencies: (json['bundledDependencies'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      engines: (json['engines'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
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
      if (instance.description case final value?) 'description': value,
      if (instance.keywords case final value?) 'keywords': value,
      if (instance.homePage case final value?) 'homepage': value,
      if (instance.bugs case final value?) 'bugs': value,
      if (instance.license case final value?) 'license': value,
      if (instance.author case final value?) 'author': value,
      if (instance.funding case final value?) 'funding': value,
      if (instance.contributors case final value?) 'contributors': value,
      if (instance.repository case final value?) 'repository': value,
      if (instance.files case final value?) 'files': value,
      if (instance.exports case final value?) 'exports': value,
      if (instance.dependencies case final value?) 'dependencies': value,
      if (instance.main case final value?) 'main': value,
      if (instance.browser case final value?) 'browser': value,
      if (instance.bin case final value?) 'bin': value,
      if (instance.directories?.toJson() case final value?)
        'directories': value,
      if (instance.scripts case final value?) 'scripts': value,
      if (instance.config case final value?) 'config': value,
      if (instance.devDependencies case final value?) 'devDependencies': value,
      if (instance.peerDependencies case final value?)
        'peerDependencies': value,
      if (instance.optionalDependencies case final value?)
        'optionalDependencies': value,
      if (instance.bundledDependencies case final value?)
        'bundledDependencies': value,
      if (instance.engines case final value?) 'engines': value,
      if (instance.os case final value?) 'os': value,
      if (instance.cpu case final value?) 'cpu': value,
      if (instance.libc case final value?) 'libc': value,
      if (instance.private case final value?) 'private': value,
      if (instance.readme case final value?) 'readme': value,
      if (instance.readmeFilename case final value?) 'readmeFilename': value,
    };

PackageJsonDirectories _$PackageJsonDirectoriesFromJson(Map json) =>
    PackageJsonDirectories(
      man: json['man'] as String?,
      lib: json['lib'] as String?,
      doc: json['doc'] as String?,
    );

Map<String, dynamic> _$PackageJsonDirectoriesToJson(
        PackageJsonDirectories instance) =>
    <String, dynamic>{
      if (instance.man case final value?) 'man': value,
      if (instance.lib case final value?) 'lib': value,
      if (instance.doc case final value?) 'doc': value,
    };

PackageJsonFunding _$PackageJsonFundingFromJson(Map json) => PackageJsonFunding(
      type: json['type'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$PackageJsonFundingToJson(PackageJsonFunding instance) =>
    <String, dynamic>{
      if (instance.type case final value?) 'type': value,
      if (instance.url case final value?) 'url': value,
    };

PackageJsonAuthor _$PackageJsonAuthorFromJson(Map json) => PackageJsonAuthor(
      name: json['name'] as String?,
      email: json['email'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$PackageJsonAuthorToJson(PackageJsonAuthor instance) =>
    <String, dynamic>{
      if (instance.name case final value?) 'name': value,
      if (instance.email case final value?) 'email': value,
      if (instance.url case final value?) 'url': value,
    };

PackageJsonRepository _$PackageJsonRepositoryFromJson(Map json) =>
    PackageJsonRepository(
      type: json['type'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$PackageJsonRepositoryToJson(
        PackageJsonRepository instance) =>
    <String, dynamic>{
      if (instance.type case final value?) 'type': value,
      if (instance.url case final value?) 'url': value,
    };

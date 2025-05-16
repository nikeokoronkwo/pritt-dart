// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NpmMetaResult _$NpmMetaResultFromJson(Map<String, dynamic> json) =>
    NpmMetaResult(
      id: json['_id'] as String,
      name: json['name'] as String,
      rev: json['_rev'] as String?,
      distTags: NpmDistTags.fromJson(json['dist-tags'] as Map<String, dynamic>),
      versions: (json['versions'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, NpmPackage.fromJson(e as Map<String, dynamic>)),
      ),
      maintainers: json['maintainers'] as List<dynamic>,
      time: Map<String, String>.from(json['time'] as Map),
      author: json['author'] == null
          ? null
          : NpmAuthor.fromJson(json['author'] as Map<String, dynamic>),
      readme: json['readme'] as String?,
      readmeFilename: json['readmeFilename'] as String?,
      license: json['license'] as String?,
      homepage: json['homepage'] as String?,
      repository: (json['repository'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      bugs: (json['bugs'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$NpmMetaResultToJson(NpmMetaResult instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      '_rev': instance.rev,
      'dist-tags': instance.distTags,
      'versions': instance.versions,
      'maintainers': instance.maintainers.toList(),
      'time': instance.time,
      'author': instance.author,
      'readme': instance.readme,
      'readmeFilename': instance.readmeFilename,
      'license': instance.license,
      'homepage': instance.homepage,
      'repository': instance.repository,
      'bugs': instance.bugs,
    };

NpmAuthor _$NpmAuthorFromJson(Map<String, dynamic> json) => NpmAuthor(
      name: json['name'] as String,
      email: json['email'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$NpmAuthorToJson(NpmAuthor instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'url': instance.url,
    };

NpmDistTags _$NpmDistTagsFromJson(Map<String, dynamic> json) => NpmDistTags(
      beta: json['beta'] as String?,
      latest: json['latest'] as String?,
      experimental: json['experimental'] as String?,
      next: json['next'] as String?,
      canary: json['canary'] as String?,
      rc: json['rc'] as String?,
    );

Map<String, dynamic> _$NpmDistTagsToJson(NpmDistTags instance) =>
    <String, dynamic>{
      'beta': instance.beta,
      'latest': instance.latest,
      'experimental': instance.experimental,
      'next': instance.next,
      'canary': instance.canary,
      'rc': instance.rc,
    };

NpmPackage _$NpmPackageFromJson(Map<String, dynamic> json) => NpmPackage(
      id: json['_id'] as String,
      rev: json['_rev'] as String?,
      dist: NpmDist.fromJson(json['dist'] as Map<String, dynamic>),
      from: json['_from'] as String?,
      npmVersion: json['_npmVersion'] as String?,
      npmUser: json['_npmUser'],
      maintainers: (json['maintainers'] as List<dynamic>?)
          ?.map((e) => NpmAuthor.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      author: json['author'] == null
          ? null
          : NpmAuthor.fromJson(json['author'] as Map<String, dynamic>),
      funding: (json['funding'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      contributors: json['contributors'] as List<dynamic>?,
      repository: (json['repository'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      files:
          (json['files'] as List<dynamic>?)?.map((e) => e as String).toList(),
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
              json['directories'] as Map<String, dynamic>),
      scripts: (json['scripts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      config: json['config'] as Map<String, dynamic>?,
      devDependencies: (json['devDependencies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      peerDependencies:
          (json['peerDependencies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      optionalDependencies:
          (json['optionalDependencies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      bundledDependencies:
          (json['bundledDependencies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      engines: (json['engines'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      os: (json['os'] as List<dynamic>?)?.map((e) => e as String).toList(),
      cpu: (json['cpu'] as List<dynamic>?)?.map((e) => e as String).toList(),
      libc: json['libc'] as String?,
      readme: json['readme'] as String?,
      readmeFilename: json['readmeFilename'] as String?,
    );

Map<String, dynamic> _$NpmPackageToJson(NpmPackage instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'description': instance.description,
      'keywords': instance.keywords,
      'homepage': instance.homePage,
      'bugs': instance.bugs,
      'license': instance.license,
      'author': instance.author,
      'funding': instance.funding,
      'contributors': instance.contributors,
      'repository': instance.repository,
      'files': instance.files,
      'exports': instance.exports,
      'dependencies': instance.dependencies,
      'main': instance.main,
      'browser': instance.browser,
      'bin': instance.bin,
      'directories': instance.directories,
      'scripts': instance.scripts,
      'config': instance.config,
      'devDependencies': instance.devDependencies,
      'peerDependencies': instance.peerDependencies,
      'optionalDependencies': instance.optionalDependencies,
      'bundledDependencies': instance.bundledDependencies,
      'engines': instance.engines,
      'os': instance.os,
      'cpu': instance.cpu,
      'libc': instance.libc,
      'readme': instance.readme,
      'readmeFilename': instance.readmeFilename,
      '_id': instance.id,
      '_rev': instance.rev,
      'dist': instance.dist,
      '_from': instance.from,
      '_npmVersion': instance.npmVersion,
      '_npmUser': instance.npmUser,
      'maintainers': instance.maintainers,
    };

NpmDist _$NpmDistFromJson(Map<String, dynamic> json) => NpmDist(
      shasum: json['shasum'] as String,
      tarball: json['tarball'] as String,
      integrity: json['integrity'] as String,
      signatures: (json['signatures'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map)),
    );

Map<String, dynamic> _$NpmDistToJson(NpmDist instance) => <String, dynamic>{
      'shasum': instance.shasum,
      'tarball': instance.tarball,
      'integrity': instance.integrity,
      'signatures': instance.signatures.toList(),
    };

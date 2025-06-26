// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NpmMetaResult _$NpmMetaResultFromJson(Map json) => NpmMetaResult(
      id: json['_id'] as String,
      name: json['name'] as String,
      rev: json['_rev'] as String?,
      distTags: NpmDistTags.fromJson(
          Map<String, dynamic>.from(json['dist-tags'] as Map)),
      versions: (json['versions'] as Map).map(
        (k, e) => MapEntry(k as String,
            NpmPackage.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      maintainers: json['maintainers'] as List<dynamic>,
      time: Map<String, String>.from(json['time'] as Map),
      author: json['author'] == null
          ? null
          : NpmAuthor.fromJson(
              Map<String, dynamic>.from(json['author'] as Map)),
      readme: json['readme'] as String?,
      readmeFilename: json['readmeFilename'] as String?,
      license: json['license'] as String?,
      homepage: json['homepage'] as String?,
      repository: (json['repository'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      bugs: (json['bugs'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
    );

Map<String, dynamic> _$NpmMetaResultToJson(NpmMetaResult instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      if (instance.rev case final value?) '_rev': value,
      'dist-tags': instance.distTags.toJson(),
      'versions': instance.versions.map((k, e) => MapEntry(k, e.toJson())),
      'maintainers': instance.maintainers.toList(),
      'time': instance.time,
      if (instance.author?.toJson() case final value?) 'author': value,
      if (instance.readme case final value?) 'readme': value,
      if (instance.readmeFilename case final value?) 'readmeFilename': value,
      if (instance.license case final value?) 'license': value,
      if (instance.homepage case final value?) 'homepage': value,
      if (instance.repository case final value?) 'repository': value,
      if (instance.bugs case final value?) 'bugs': value,
    };

NpmAuthor _$NpmAuthorFromJson(Map json) => NpmAuthor(
      name: json['name'] as String,
      email: json['email'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$NpmAuthorToJson(NpmAuthor instance) => <String, dynamic>{
      'name': instance.name,
      if (instance.email case final value?) 'email': value,
      if (instance.url case final value?) 'url': value,
    };

NpmDistTags _$NpmDistTagsFromJson(Map json) => NpmDistTags(
      beta: json['beta'] as String?,
      latest: json['latest'] as String?,
      experimental: json['experimental'] as String?,
      next: json['next'] as String?,
      canary: json['canary'] as String?,
      rc: json['rc'] as String?,
    );

Map<String, dynamic> _$NpmDistTagsToJson(NpmDistTags instance) =>
    <String, dynamic>{
      if (instance.beta case final value?) 'beta': value,
      if (instance.latest case final value?) 'latest': value,
      if (instance.experimental case final value?) 'experimental': value,
      if (instance.next case final value?) 'next': value,
      if (instance.canary case final value?) 'canary': value,
      if (instance.rc case final value?) 'rc': value,
    };

NpmPackage _$NpmPackageFromJson(Map json) => NpmPackage(
      id: json['_id'] as String,
      rev: json['_rev'] as String?,
      dist: NpmDist.fromJson(Map<String, dynamic>.from(json['dist'] as Map)),
      from: json['_from'] as String?,
      npmVersion: json['_npmVersion'] as String?,
      npmUser: json['_npmUser'],
      maintainers: (json['maintainers'] as List<dynamic>?)
          ?.map((e) => NpmAuthor.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
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
      author: json['author'] == null
          ? null
          : NpmAuthor.fromJson(
              Map<String, dynamic>.from(json['author'] as Map)),
      funding: (json['funding'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      contributors: json['contributors'] as List<dynamic>?,
      repository: (json['repository'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
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
      readme: json['readme'] as String?,
      readmeFilename: json['readmeFilename'] as String?,
    );

Map<String, dynamic> _$NpmPackageToJson(NpmPackage instance) =>
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
      if (instance.readme case final value?) 'readme': value,
      if (instance.readmeFilename case final value?) 'readmeFilename': value,
      '_id': instance.id,
      if (instance.rev case final value?) '_rev': value,
      'dist': instance.dist.toJson(),
      if (instance.from case final value?) '_from': value,
      if (instance.npmVersion case final value?) '_npmVersion': value,
      if (instance.npmUser case final value?) '_npmUser': value,
      if (instance.maintainers?.map((e) => e.toJson()).toList()
          case final value?)
        'maintainers': value,
    };

NpmDist _$NpmDistFromJson(Map json) => NpmDist(
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

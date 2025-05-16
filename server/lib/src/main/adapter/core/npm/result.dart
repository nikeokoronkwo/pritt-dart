import 'package:json_annotation/json_annotation.dart';
import '../../adapter_base.dart';
import 'package_json.dart';

part 'result.g.dart';

/// The result of a dart meta (i.e [AdapterResolve.meta]) request
@JsonSerializable()
class NpmMetaResult with MetaResult {
  /// The id
  @JsonKey(name: '_id')
  final String id;

  /// The name of the package
  final String name;

  /// The revision of the package
  @JsonKey(name: '_rev')
  final String? rev;

  /// The dist tags of the package
  @JsonKey(name: 'dist-tags')
  final NpmDistTags distTags;

  /// A map of all the versions of the package to their respective package metadata
  final Map<String, NpmPackage> versions;

  /// The maintainers of the package
  final Iterable<dynamic> maintainers;

  /// The time when each package version was published
  final Map<String, String> time;

  /// The author of the package
  final NpmAuthor? author;

  /// The package readme
  final String? readme;

  /// The package readme filename
  final String? readmeFilename;

  /// The license of the package
  final String? license;

  /// The homepage of the package
  final String? homepage;

  /// The repository of the package
  final Map<String, String>? repository;

  /// The bugs of the package
  final Map<String, String>? bugs;

  const NpmMetaResult({
    required this.id,
    required this.name,
    this.rev,
    required this.distTags,
    required this.versions,
    required this.maintainers,
    required this.time,
    this.author,
    this.readme,
    this.readmeFilename,
    this.license,
    this.homepage,
    this.repository,
    this.bugs,
  });

  factory NpmMetaResult.fromJson(Map<String, dynamic> json) =>
      _$NpmMetaResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NpmMetaResultToJson(this);
}

@JsonSerializable()
class NpmAuthor {
  /// The name of the author
  final String name;

  /// The email of the author
  final String? email;

  /// The url of the author
  final String? url;

  const NpmAuthor({
    required this.name,
    this.email,
    this.url,
  });

  factory NpmAuthor.fromJson(Map<String, dynamic> json) =>
      _$NpmAuthorFromJson(json);

  Map<String, dynamic> toJson() => _$NpmAuthorToJson(this);
}

/// Example:
// "dist-tags": {
//   "beta": "19.0.0-beta-26f2496093-20240514",
//   "rc": "19.0.0-rc.1",
//   "latest": "19.1.0",
//   "experimental": "0.0.0-experimental-21fdf308-20250508",
//   "next": "19.2.0-canary-21fdf308-20250508",
//   "canary": "19.2.0-canary-21fdf308-20250508"
// },
@JsonSerializable()
class NpmDistTags {
  /// The beta version
  final String? beta;

  /// The latest version
  final String? latest;

  /// The experimental version
  final String? experimental;

  /// The next version
  final String? next;

  /// The canary version
  final String? canary;

  /// The rc version
  final String? rc;

  const NpmDistTags({
    this.beta,
    this.latest,
    this.experimental,
    this.next,
    this.canary,
    this.rc,
  });

  factory NpmDistTags.fromJson(Map<String, dynamic> json) =>
      _$NpmDistTagsFromJson(json);

  Map<String, dynamic> toJson() => _$NpmDistTagsToJson(this);
}

/// Example: {
//   "name": "rex",
//   "version": "0.1.0",
//   "description": "the king of browser dependencies",
//   "keywords": [
//     "browser",
//     "js",
//     "common.js"
//   ],
//   "dependencies": {
//     "common": "\u003E=0.1.0"
//   },
//   "author": {
//     "name": "Mathias Buus Madsen",
//     "email": "mathiasbuus@gmail.com"
//   },
//   "main": "./index.js",
//   "_npmJsonOpts": {
//     "file": "/Users/maf/.npm/rex/0.1.0/package/package.json",
//     "wscript": false,
//     "contributors": false,
//     "serverjs": false
//   },
//   "_id": "rex@0.1.0",
//   "devDependencies": {

//   },
//   "engines": {
//     "node": "*"
//   },
//   "_engineSupported": true,
//   "_npmVersion": "1.0.15",
//   "_nodeVersion": "v0.4.9",
//   "_defaultsLoaded": true,
//   "dist": {
//     "shasum": "a24e63715fe591a11aa2ae99bec621c5aab730fc",
//     "tarball": "https://registry.npmjs.org/rex/-/rex-0.1.0.tgz",
//     "integrity": "sha512-TXk+/Zhpu8G1+JFE+f6DbM/uem7jkes/0O3VnExq9GE/yPIuUaEmXUDtPY8WhWevu+43EnzBjb3LS+E0pauIPA==",
//     "signatures": [
//       {
//         "keyid": "SHA256:jl3bwswu80PjjokCgh0o2w5c2U4LhQAE57gj9cz1kzA",
//         "sig": "MEUCIQDghiCvZ3nLqxq2uk6BziiLbJH43ULLgMg9YCWFqDSfdgIgWmH9Vu4KOQtShQzBo7FnSyqKBSqM0Gs/chdCRGKXuOE="
//       }
//     ]
//   },
//   "scripts": {

//   },
//   "maintainers": [
//     {
//       "name": "mafintosh",
//       "email": "m@ge.tt"
//     }
//   ],
//   "directories": {

//   }
// }
@JsonSerializable()
class NpmPackage extends PackageJson {
  /// The id of the package
  @JsonKey(name: '_id')
  final String id;

  /// The revision of the package
  @JsonKey(name: '_rev')
  final String? rev;

  /// The dist metadata of the package
  final NpmDist dist;

  /// _from
  @JsonKey(name: '_from')
  final String? from;

  /// _npmVersion
  @JsonKey(name: '_npmVersion')
  final String? npmVersion;

  /// _npmUser
  @JsonKey(name: '_npmUser')
  final dynamic npmUser;

  /// maintainers
  final List<NpmAuthor>? maintainers;

  const NpmPackage({
    required this.id,
    this.rev,
    required this.dist,
    this.from,
    this.npmVersion,
    this.npmUser,
    this.maintainers,
    required super.name,
    required super.version,
    super.description,
    super.keywords,
    super.homePage,
    super.bugs,
    super.license,
    NpmAuthor? super.author,
    Map<String, String>? super.funding,
    super.contributors,
    Map<String, String>? super.repository,
    super.files,
    super.exports,
    super.dependencies,
    super.main,
    super.browser,
    super.bin,
    super.directories,
    super.scripts,
    super.config,
    super.devDependencies,
    super.peerDependencies,
    super.optionalDependencies,
    super.bundledDependencies,
    super.engines,
    super.os,
    super.cpu,
    super.libc,
    super.readme,
    super.readmeFilename,
  })  : assert(npmUser is NpmAuthor? ||
            npmUser is String? ||
            npmUser is Map<String, String>?),
        super(
          private: false,
        );

  factory NpmPackage.fromPackageJson(
    PackageJson package, {
    required String id,
    String? rev,
    required NpmDist dist,
    String? from,
    String? npmVersion,
    dynamic npmUser,
    List<NpmAuthor>? maintainers,
  }) =>
      NpmPackage(
        id: id,
        rev: rev,
        dist: dist,
        from: from,
        npmVersion: npmVersion,
        npmUser: npmUser,
        maintainers: maintainers,
        name: package.name,
        version: package.version,
        description: package.description,
        keywords: package.keywords,
        homePage: package.homePage,
        bugs: package.bugs,
        license: package.license,
        author: package.author,
        funding: package.funding,
        contributors: package.contributors,
        repository: package.repository,
        files: package.files,
        exports: package.exports,
        dependencies: package.dependencies,
        main: package.main,
        browser: package.browser,
        bin: package.bin,
        directories: package.directories,
        scripts: package.scripts,
        config: package.config,
        devDependencies: package.devDependencies,
        peerDependencies: package.peerDependencies,
        optionalDependencies: package.optionalDependencies,
        bundledDependencies: package.bundledDependencies,
        engines: package.engines,
        os: package.os,
        cpu: package.cpu,
        libc: package.libc,
        readme: package.readme,
        readmeFilename: package.readmeFilename,
      );

  factory NpmPackage.fromJson(Map<String, dynamic> json) =>
      _$NpmPackageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NpmPackageToJson(this);
}

@JsonSerializable()
class NpmDist {
  /// The shasum of the package
  final String shasum;

  /// The tarball of the package
  final String tarball;

  /// The integrity of the package
  final String integrity;

  /// The signatures of the package
  final Iterable<Map<String, String>> signatures;

  const NpmDist({
    required this.shasum,
    required this.tarball,
    required this.integrity,
    required this.signatures,
  });

  factory NpmDist.fromJson(Map<String, dynamic> json) =>
      _$NpmDistFromJson(json);

  Map<String, dynamic> toJson() => _$NpmDistToJson(this);
}

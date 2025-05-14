import 'package:pritt_server/src/lib/crs/db/annotations.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v6.dart';

import '../../shared/version.dart';

enum Privileges { read, write, publish, ultimate }

enum VCS { git, svn, fossil, mercurial, other }

/// A package, as represented in the pritt database
class Package {
  /// The id of the package
  @primary
  Uuid id;

  /// The name of the package
  @unique
  String name;

  /// The latest version of the given package
  /// updated with every publish to the database
  String version;

  /// The person who published the given package
  ///
  /// This is a foreign reference to a user
  User author;

  /// The configuration file used for the given package
  String? config;

  /// SHA256 Hash data about the
  String hash;

  /// The last published time of the given package
  DateTime updated;

  /// The first published time of the given package
  DateTime created;

  /// The VCS that the package uses for development
  ///
  /// This information is not used at the moment, and is reserved for future iterations
  VCS vcs;

  /// The archive path of the given package.
  ///
  /// This archive is usually for the Object File System and so is relative to that
  Uri archive;

  /// The contributors to the package
  ///
  Iterable<User> contributors;

  Package(
      {
      this.id = const Uuid(),
      required this.name,
      required this.version,
      required this.author,
      this.config,
      required this.hash,
      DateTime? updated,
      required this.created,
      this.vcs = VCS.git,
      required this.archive,
      required this.contributors})
      : updated = updated ?? created;
}

/// Maps packages to their versions, and info about those versions
class PackageVersions {

  @primary
  @ForeignKey(Package, property: 'id')
  Package package;

  String version;

  /// The type of version here
  VersionType versionType;

  /// The published time of the given package
  DateTime created;

  /// The path to the readme of the given package relative to where the package is
  Uri? readme;

  /// The raw contents of the config file associated with the config
  String? config;

  /// The name of the configuration file used for the given package
  String? configName;

  /// Some info about this package, like the size and more
  Map<String, dynamic> info;

  /// Environment information (runtime, package manager versions, etc)
  Map<String, String> env;

  /// Metadata about the package
  ///
  /// This varies between programming languages based on schema
  Map<String, dynamic> metadata;

  /// The archive path of the given package.
  ///
  /// This archive is usually for the Object File System and so is relative to that
  Uri archive;

  /// The archive SHA256 hash data
  String hash;

  /// Signatures for the given package when published
  List<Signature> signatures;

  /// The integrity hash of the given package
  String integrity;

  /// Whether the given package is deprecated
  bool isDeprecated;

  /// Whether a given package is yanked
  bool isYanked;

  PackageVersions(
      {required this.package,
      required this.version,
      required this.versionType,
      DateTime? updated,
      required this.created,
      this.readme,
      this.config,
      this.configName,
      required this.info,
      required this.env,
      required this.metadata,
      required this.archive,
      required this.hash,
      required this.signatures,
      required this.integrity,
      this.isDeprecated = false,
      this.isYanked = false})
      : assert(config == null || configName != null,
            "If config is set, then configName must be set as well");
}

/// Join table for contributors for a package
class PackageContributors {
  @ForeignKey(Package, property: 'id')
  Package package;

  @ForeignKey(User, property: 'id')
  User contributor;

  /// The kind of privileges this contributor has, when contributing to this package.
  ///
  /// No contributor can have [Privileges.ultimate] except the author himself, unless he passes the package down to another person (not possible in pritt yet)
  ///
  /// Users can have a combination of privileges.
  Iterable<Privileges> privileges;

  PackageContributors({
    required this.package,
    required this.contributor,
    required this.privileges,
  });
}

/// User information
///
/// TODO: Auth?
class User {
  /// The id of the user
  @primary
  Uuid id;

  /// The name of the user
  String name;

  /// The current access token for the given user
  ///
  /// This is used for authenticating workflows for the CLI, installing packages, etc
  String accessToken;

  /// When the current access token expires
  DateTime accessTokenExpiresAt;

  /// The email address of the user
  String email;

  /// The time the user joined
  DateTime createdAt;

  /// The last time the user updated information
  DateTime updatedAt;

  User({
    this.id = const Uuid(),
    required this.name,
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.email,
    required this.createdAt,
    required this.updatedAt
  });
}

class Signature {
  /// The public key id of the signature
  String publicKeyId;

  /// The signature itself
  String signature;

  /// The time the signature was created
  DateTime created;

  Signature({
    required this.publicKeyId,
    required this.signature,
    required this.created,
  });
}

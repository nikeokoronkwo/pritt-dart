import 'package:json_annotation/json_annotation.dart';

import '../../utils/version.dart';
import 'annotations/schema.dart';

part 'schema.g.dart';

enum Privileges {
  read,
  write,
  publish,
  ultimate;

  static Privileges fromString(String name) {
    return Privileges.values
        .singleWhere((v) => v.toString() == name.toLowerCase());
  }
}

enum VCS {
  git,
  svn,
  fossil,
  mercurial,
  other;

  static VCS fromString(String name) {
    return VCS.values.singleWhere((v) => v.toString() == name.toLowerCase());
  }
}

/// A package, as represented in the pritt database
class Package {
  /// The id of the package
  @primary
  String id;

  /// The name of the package
  @unique
  String name;

  /// The description of the package
  String? description;

  /// The latest version of the given package
  /// updated with every publish to the database
  String version;

  /// The person who published the given package
  ///
  /// This is a foreign reference to a user
  User author;

  /// The programming language
  String language;

  /// The last published time of the given package
  DateTime updated;

  /// The first published time of the given package
  DateTime created;

  /// The VCS that the package uses for development
  ///
  /// This information is not used at the moment, and is reserved for future iterations
  VCS vcs;

  /// The VCS URL of the package, if applicable
  Uri? vcsUrl;

  /// The archive directory path of the given package.
  ///
  /// This archive is usually for the Object File System and so is relative to that
  Uri archive;

  /// The license of the given package
  String? license;

  /// Whether a package is scoped or not
  bool get scoped => scope != null;

  /// The scope of the package, if it is scoped
  String? scope;

  Package(
      {required this.id,
      required this.name,
      required this.version,
      required this.author,
      required this.language,
      this.description,
      DateTime? updated,
      required this.created,
      this.vcs = VCS.git,
      required this.archive,
      this.license,
      this.scope,
      this.vcsUrl})
      : updated = updated ?? created;
}

/// Maps packages to their versions, and info about those versions
class PackageVersions {
  @primary
  @ForeignKey(Package, property: 'name')
  Package package;

  String version;

  /// The type of version here
  VersionType versionType;

  /// The published time of the given package
  DateTime created;

  /// The contents of the readme file associated with the package
  String? readme;

  /// The raw contents of the config file associated with the config
  String? config;

  /// The name of the configuration file used for the given package
  String? configName;

  /// Some info about this package, like the size and more
  Map<String, dynamic> info;

  /// Environment information (runtime, package manager versions, etc)
  /// e.g npm, node
  Map<String, String> env;

  /// Metadata about the package
  ///
  /// This varies between programming languages based on schema
  /// e.g npmUser
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

  /// A deprecation message for the given package
  String? deprecationMessage;

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
      this.isYanked = false,
      this.deprecationMessage})
      : assert(config == null || configName != null,
            "If config is set, then configName must be set as well");
}

/// Join table for contributors for a package
class PackageContributors {
  @ForeignKey(Package, property: 'id')
  Package package;

  @ForeignKey(User, property: 'id')
  User contributor;

  /// When the contributor was added to the package
  DateTime addedAt;

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
    required this.addedAt,
  }) : assert(
            privileges.contains(Privileges.ultimate) && privileges.length == 1,
            "Ultimate privilege cannot be combined with read privilege");
}

/// User information
///
/// TODO: Auth?
class User {
  /// The id of the user
  @primary
  String id;

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

  User(
      {required this.id,
      required this.name,
      required this.accessToken,
      required this.accessTokenExpiresAt,
      required this.email,
      required this.createdAt,
      required this.updatedAt});
}

/// A scope is an organizational unit for packages
class Scope {
  /// The id of the scope
  @primary
  String id;

  /// The name of the scope
  @unique
  String name;

  /// The description of the scope
  String? description;

  /// The time the scope was created
  DateTime createdAt;

  /// The time the scope was last updated
  DateTime updatedAt;

  Scope({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// A join table for users and scopes
@Table('organization_members')
class ScopeUsers {
  @ForeignKey(Scope, property: 'id')
  @Key(name: 'organization_id')
  Scope scope;

  @ForeignKey(User, property: 'id')
  @Key(name: 'user_id')
  User user;

  /// The privileges the user has in the scope
  Iterable<Privileges> privileges;

  /// When the user was added to the scope
  DateTime joinedAt;

  ScopeUsers({
    required this.scope,
    required this.user,
    required this.privileges,
    required this.joinedAt,
  });
}

@JsonSerializable()
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

  factory Signature.fromJson(Map<String, dynamic> json) =>
      _$SignatureFromJson(json);
  Map<String, dynamic> toJson() => _$SignatureToJson(this);
}

class Plugin {
  @primary
  String id;

  String name;

  String language;

  String? description;

  Uri archive;

  PluginArchiveType archiveType;

  Plugin({
    required this.id,
    required this.name,
    required this.language,
    this.description,
    required this.archive,
    this.archiveType = PluginArchiveType.single,
  });
}

enum PluginArchiveType { single, multi }

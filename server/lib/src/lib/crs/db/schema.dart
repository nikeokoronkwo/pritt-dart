enum VersionType {
  major,
  experimental,
  beta,
  next,
  rc,
  canary,
}

enum Privileges {
  read, write, publish, ultimate
}

enum VCS {
  git, svn, fossil, mercurial, other
}


/// A package, as represented in the pritt database
class Package {
  /// The name of the package
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

  Package({
    required this.name,
    required this.version,
    required this.author,
    this.config,
    required this.hash,
    DateTime? updated,
    required this.created,
    this.vcs = VCS.git,
    required this.archive,
  }) : updated = updated ?? created;


}

/// Maps packages to their versions, and info about those versions
class PackageVersions {
    Package package;

    String version;

    /// The type of version here
    VersionType versionType;

    /// The last published time of the given package
    DateTime updated;

    /// The first published time of the given package
    DateTime created;

    /// The path to the readme of the given package relative to where the package is
    Uri? readme;

    /// The config file associated with the config
    Map<String, dynamic>? config;

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

  PackageVersions({
    required this.package,
    required this.version,
    required this.versionType,
    DateTime? updated,
    required this.created,
    this.readme,
    this.config,
    required this.info,
    required this.env,
    required this.metadata,
    required this.archive,
  }) : updated = updated ?? created;
}

/// Join table for contributors for a package
class PackageContributors {
    Package package;

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
  String id;

  /// The current access token for the given user
  /// 
  /// This is used for authenticating workflows for the CLI, installing packages, etc
  String accessToken;

  /// The email address of the user
  String emailAddress;

  /// The time the user joined
  DateTime joined;

  User({
    required this.id,
    required this.accessToken,
    required this.emailAddress,
    required this.joined,
  });
}
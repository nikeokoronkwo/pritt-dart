import 'dart:async';

import 'package:pritt_common/version.dart';

import 'annotations/cache.dart';
import 'schema.dart';

/// Base interface for a SQL database interface
///
mixin SQLDatabase {
  FutureOr sql(String statement);
}

/// An interface for working with adapters via the DB
///
/// This is usually implemented by a local SQLITE instance in development (or where needed)
///
/// For now, this usually acts as the source of truth for custom adapter services, but depending on how adapter development and usage scales, adapters might be loaded on service side.
abstract interface class PrittAdapterDatabaseInterface {
  /// Get an adapter by id
  FutureOr<Plugin> getPlugin(String id);

  /// Get all adapters for a given language
  FutureOr<Iterable<Plugin>> getPluginsByLanguage(String language);

  /// Get all adapters for a given set of languages
  FutureOr<Iterable<Plugin>> getPluginsForLanguages(Set<String> languages);

  /// Get all adapters
  FutureOr<Iterable<Plugin>> getPlugins();
}

/// An extension of [PrittAdapterDatabaseInterface] for databases that support storing blobs and can store enough to contain adapter code
///
/// This is usually very unlikely, but we can see
abstract interface class PrittAdapterWithBlobDatabaseInterface
    extends PrittAdapterDatabaseInterface {
  /// Get the code for an adapter by id
  FutureOr<Map<String, String>> getPluginCode(String id);

  /// Stream the code for an adapter by id
  FutureOr<Map<String, Stream<List<int>>>> streamPluginCode(String id);
}

/// Base interface for the CRS Database Interface
///
/// This is a database-agnostic interface that defines methods for retrieving different kinds of data from the CRS database
abstract interface class PrittDatabaseInterface
    extends PrittAdapterDatabaseInterface {
  /// add a new package to the database
  FutureOr<Package> addNewPackage({
    required String name,
    String? scope,
    String? description,
    required String version,
    required User author,
    required String language,
    required VCS vcs,
    String? vcsUrl,
    String? license,
    required Uri archive,
    Iterable<User>? contributors,
  });

  /// adds a new version of a package to the database
  ///
  /// Adds a new [PackageVersions] to the database and updates the version of the associated [Package]
  /// (i.e [Package.version])
  FutureOr<PackageVersions> addNewVersionOfPackage({
    required String name,
    String? scope,
    required String version,
    VersionType? versionType,
    String? description,
    required String hash,
    required String signature,
    required String integrity,
    String? readme,
    String? config,
    String? configName,
    Map<String, dynamic> info = const {},
    Map<String, String> env = const {},
    Map<String, dynamic> metadata = const {},
    required User author,
    required String language,
    required VCS vcs,
    required Uri archive,
    Iterable<String>? contributors,
  });

  /// Add a user as a contributor to a package
  FutureOr<Package> addContributorToPackage(
      String name, User user, List<Privileges> privileges,
      {String? scope});

  /// Updates a new version of a package with archive details such as hash, signature, integrity, etc
  FutureOr<PackageVersions> updateNewPackageWithArchiveDetails({
    required String name,
    required String version,
    required String hash,
    required String signature,
    required String integrity,
  });

  /// update a package with new information
  FutureOr<Package> updatePackage(
      String name, Package Function(Package) updates,
      {String? scope});

  /// update a version of a package with new information
  FutureOr<Package> updateVersionOfPackage(String name, Version version,
      PackageVersions Function(PackageVersions) updates,
      {String? scope});

  /// Yanks a given version of a package
  FutureOr<PackageVersions> yankVersionOfPackage(String name, Version version,
      {String? scope});

  /// Deprecates a given version of a package
  FutureOr<PackageVersions> deprecateVersionOfPackage(
      String name, Version version,
      {String? scope});

  /// Get a package
  FutureOr<Package> getPackage(String name, {String? language, String? scope});

  /// Get a specific version of a package
  FutureOr<PackageVersions> getPackageWithVersion(String name, Version version,
      {String? scope});

  /// Get all versions of a package
  FutureOr<Iterable<PackageVersions>> getAllVersionsOfPackage(String name,
      {Package? package, String? scope});

  /// Get all versions of a package via [Stream]
  Stream<PackageVersions> getAllVersionsOfPackageStream(String name,
      {String? scope});

  /// Get packages
  FutureOr<Iterable<Package>> getPackages();

  /// Get the number of packages in the registry
  ///
  /// This is slow, and you should use [getPackagesCountEstimate] unless you need an exact value
  FutureOr<int> getPackagesCount();

  /// Get the estimate of the number of packages in the registry
  FutureOr<int> getPackagesCountEstimate();

  /// Get packages via [Stream]
  Stream<Package> getPackagesStream();

  /// Get packages for a specific user
  FutureOr<Iterable<Package>> getPackagesForUser(String id);

  /// Get packages for a specific user via [Stream]
  Stream<Package> getPackagesForUserStream(String id);

  /// Get contributors for a specific package
  FutureOr<Map<User, Iterable<Privileges>>> getContributorsForPackage(
      String name,
      {String? scope});

  /// Get contributors for a specific package via [Stream]
  Stream<User> getContributorsForPackageStream(String name);

  /// Create a user
  FutureOr<User> createUser({
    required String name,
    required String email,
  });

  /// Update a user
  FutureOr<User> updateUser({
    required String name,
    required String email,
    User Function(User)? updates,
  });

  /// Create a new access token for a user
  FutureOr<(AccessToken, {String token})> createAccessTokenForUser(
      {required String id,
      AccessTokenType tokenType = AccessTokenType.device,
      String? description,
      String? deviceId,
      Map<String, dynamic>? deviceInfo});

  /// Get a user
  FutureOr<User> getUser(String id);

  /// Get a user by email
  FutureOr<User> getUserByEmail(String email);

  /// Get all users
  FutureOr<Iterable<User>> getUsers();

  /// Get all users via [Stream]
  Stream<User> getUsersStream();

  /// Set the access token for a user
  FutureOr<(AccessToken, {String token})> setAccessTokenForUser(
      {required String id,
      required String accessToken,
      required DateTime expiresAt,
      AccessTokenType tokenType = AccessTokenType.device,
      String? description,
      String? deviceId,
      Map<String, dynamic>? deviceInfo});

  /// Get a user by access token
  FutureOr<User> getUserByAccessToken(String accessToken);

  /// Get the organizations a user is part of
  FutureOr<Iterable<Scope>> getOrganizationsForUser(String id);

  /// Get the organizations a user is part of via [Stream]
  Stream<Scope> getOrganizationsForUserStream(String id);

  /// Get organization information given the name of the organization
  FutureOr<Scope> getOrganizationByName(String name);

  /// Get all organizations
  FutureOr<Iterable<Scope>> getOrganizations();

  /// Get all organizations via [Stream]
  Stream<Scope> getOrganizationsStream();

  /// Create a new organization
  FutureOr<Scope> createOrganization({
    required String name,
    String? description,
    required User owner,
  });

  /// Update an organization
  FutureOr<Scope> updateOrganization({
    required String name,
    Scope Function(Scope)? updates,
  });

  /// Get packages for a specific organization by its [name]
  FutureOr<Iterable<Package>> getPackagesForOrganization(String name);

  /// Get packages for a specific organization via [Stream]
  Stream<Package> getPackagesForOrganizationStream(String name);

  /// Get all members of an organization
  FutureOr<Map<User, Iterable<Privileges>>> getMembersForOrganization(
      String name);

  /// Get all members of an organization via [Stream]
  Stream<User> getMembersForOrganizationStream(String name);

  /// Add a user to an organization
  FutureOr<ScopeUsers> addUserToOrganization({
    required String organizationName,
    required User user,
    Iterable<Privileges> privileges = const [],
  });

  /// Remove a user from an organization
  FutureOr<ScopeUsers> removeUserFromOrganization({
    required String organizationName,
    required User user,
  });

  /// Update a user's privileges in an organization
  FutureOr<ScopeUsers> updateUserPrivilegesInOrganization({
    required String organizationName,
    required User user,
    Iterable<Privileges> privileges = const [],
  });

  /// Add a new authorization request and generate an auth token to use
  @Cacheable()
  Future<AuthorizationSession> createNewAuthSession({
    required String deviceId,
  });

  /// Gets the status of a current auth sessions
  @Cacheable()
  Future<({TaskStatus status, String? id})> getAuthSessionStatus({
    required String sessionId,
  });

  /// Gets current auth session details
  @Cacheable()
  Future<AuthorizationSession> getAuthSessionDetails({
    required String sessionId,
  });

  /// Updates an auth session with a user's credentials
  @Cacheable()
  Future<AuthorizationSession> completeAuthSession(
      {required String sessionId,
      required String userId,
      TaskStatus? newStatus});

  /// Update an auth session, and get the access token for the session
  Future<
      ({
        AuthorizationSession session,
        String token,
        DateTime tokenExpiration
      })> updateAuthSessionWithAccessToken({required String sessionId});

  /// Creates a new publishing task
  @Cacheable()
  FutureOr<PublishingTask> createNewPublishingTask(
      {required String name,
      String? scope,
      required String version,
      required User user,
      required String language,
      bool newPkg = false,
      required String config,
      required Map<String, dynamic> configData,
      Map<String, dynamic> metadata,
      Map<String, String> env,
      VCS vcs,
      String? vcsUrl});

  /// Gets the given publishing task given its [id]
  @Cacheable()
  FutureOr<PublishingTask> getPublishingTaskById(String id);

  /// Updates a publishing task's status
  @Cacheable()
  FutureOr<PublishingTask> updatePublishingTaskStatus(String id,
      {required TaskStatus status});

  /// Elevates a publishing task to a new package, plus a new version of a package
  FutureOr<(Package, PackageVersions)> createPackageFromPublishingTask(
      String id,
      {String? description,
      String? license,
      VersionType? versionType,
      String? readme,
      required String rawConfig,
      Map<String, dynamic>? info,
      required Uri archive,
      required String hash,
      List<Signature> signatures = const [],
      required String integrity,
      PublishingTask? task,
      List<String> contributorIds = const []});

  /// Elevates a publishing task to a new version of a package
  FutureOr<PackageVersions> createPackageVersionFromPublishingTask(String id,
      {VersionType? versionType,
      String? readme,
      required String rawConfig,
      Map<String, dynamic>? info,
      required Uri archive,
      required String hash,
      List<Signature> signatures = const [],
      required String integrity,
      PublishingTask? task,
      List<String> contributorIds = const []});
}

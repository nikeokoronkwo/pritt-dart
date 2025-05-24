import 'dart:async';

import '../../utils/version.dart';
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
    required String version,
    required User author,
    required String language,
    required VCS vcs,
    Uri? archive,
    Iterable<User>? contributors,
  });

  /// adds a new version of a package to the database
  ///
  /// Adds a new [PackageVersions] to the database and updates the version of the associated [Package]
  /// (i.e [Package.version])
  FutureOr<PackageVersions> addNewVersionOfPackage({
    required String name,
    required String version,
    required User author,
    required String language,
    required VCS vcs,
    Uri? archive,
    Iterable<User>? contributors,
  });

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
      String name, Package Function(Package) updates);

  /// update a version of a package with new information
  FutureOr<Package> updateVersionOfPackage(String name, Version version,
      PackageVersions Function(PackageVersions) updates);

  /// Yanks a given version of a package
  FutureOr<PackageVersions> yankVersionOfPackage(String name, Version version);

  /// Deprecates a given version of a package
  FutureOr<PackageVersions> deprecateVersionOfPackage(
      String name, Version version);

  /// Get a package
  FutureOr<Package> getPackage(String name, {String? language});

  /// Get a specific version of a package
  FutureOr<PackageVersions> getPackageWithVersion(String name, Version version);

  /// Get all versions of a package
  FutureOr<Iterable<PackageVersions>> getAllVersionsOfPackage(String name,
      {Package? package});

  /// Get all versions of a package via [Stream]
  Stream<PackageVersions> getAllVersionsOfPackageStream(String name);

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
      String name);

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

  /// Get a user
  FutureOr<User> getUser(String id);

  /// Get a user by email
  FutureOr<User> getUserByEmail(String email);

  /// Get all users
  FutureOr<Iterable<User>> getUsers();

  /// Get all users via [Stream]
  Stream<User> getUsersStream();

  /// Set the access token for a user
  FutureOr<User> setAccessTokenForUser({
    required String id,
    required String accessToken,
    required DateTime expiresAt,
  });

  /// Get a user by access token
  FutureOr<User> getUserByAccessToken(String accessToken);
}

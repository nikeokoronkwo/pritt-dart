import 'dart:async';

import '../shared/version.dart';
import 'db/schema.dart';

/// Base interface for the CRS Database Interface
///
/// This is a database-agnostic interface that defines methods for retrieving different kinds of data from the CRS database
abstract interface class CRSDatabaseInterface {
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

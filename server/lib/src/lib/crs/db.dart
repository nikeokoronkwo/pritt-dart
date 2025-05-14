import 'dart:async';

import 'package:pritt_server/src/lib/crs/db/schema.dart';
import 'package:pritt_server/src/lib/shared/version.dart';
import 'package:uuid/uuid.dart';

/// Base interface for the CRS Database Interface
///
/// This is a database-agnostic interface that defines methods for retrieving different kinds of data from the CRS database
abstract interface class CRSDatabaseInterface {
  /// add a new package to the database
  FutureOr<Package> addNewPackage(Package pkg);

  /// adds a new version of a package to the database
  FutureOr<PackageVersions> addNewVersionOfPackage(PackageVersions pkg);

  /// update a package with new information
  FutureOr<Package> updatePackage(String name, Map<String, dynamic> updates);

  /// update a version of a package with new information
  FutureOr<Package> updateVersionOfPackage(Uuid id, Version version, Map<String, dynamic> updates);

  /// Yanks a given version of a package
  FutureOr<PackageVersions> yankVersionOfPackage(Uuid id, Version version);

  /// Deprecates a given version of a package
  FutureOr<PackageVersions> deprecateVersionOfPackage(Uuid id, Version version);

  /// Get a package
  FutureOr<Package> getPackage(Uuid id);

  /// Get packages
  FutureOr<Iterable<Package>> getPackages(Uuid id);

  /// Get packages f

  /// Get a specific version of a package
  FutureOr<PackageVersions> getVersionOfPackage();

  /// Create a user
  FutureOr<User> createUser({
    required String name,
    required String email,
  });

  /// Update a user
  FutureOr<User> updateUser({
    required String name,
    required String email,
  });
}

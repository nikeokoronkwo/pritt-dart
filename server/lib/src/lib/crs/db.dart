import 'dart:async';

import 'package:pritt_server/src/lib/crs/db/schema.dart';

/// Base interface for the CRS Database Interface
///
/// This is a database-agnostic interface that defines methods for retrieving different kinds of data from the CRS database
abstract interface class CRSDatabaseInterface {
  /// add a new package to the database
  FutureOr<Package> addNewPackage();

  /// adds a new version of a package to the database
  FutureOr<PackageVersions> addNewVersionOfPackage();

  /// update a package with new information
  FutureOr<Package> updatePackage(Map<String, dynamic> updates);

  /// update a version of a package with new information
  FutureOr<Package> updateVersionOfPackage(Map<String, dynamic> updates);

  /// Yanks a given version of a package
  FutureOr<PackageVersions> yankVersionOfPackage();

  /// Deprecates a given version of a package
  FutureOr<PackageVersions> deprecateVersionOfPackage();

  /// Get a package
  FutureOr<Package> getPackage();

  /// Get a specific version of a package
  FutureOr<PackageVersions> getVersionOfPackage();
}

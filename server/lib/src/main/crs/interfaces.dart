// ignore_for_file: constant_identifier_names

import 'dart:async';

import '../utils/version.dart';
import '../base/db/interface.dart';
import '../base/db/schema.dart';
import '../base/storage/interface.dart';
import 'response.dart';

class CRSArchive {
  final String name;

  final String? contentType;

  final Stream<List<int>> data;

  const CRSArchive(this.name, this.contentType, this.data);
  CRSArchive.empty()
      : name = '',
        contentType = null,
        data = Stream.empty();
}

/// an interface for the core registry system, used by adapters to make requests to retrieve common data
abstract interface class CRSArchiveController {
  /// The object file system interface used by the controller
  PrittStorageInterface get ofs;

  /// get the archive of a package with the given version
  ///
  /// [packageName] is the name of the package
  /// [version] is the version of the package
  /// [language] is the language of the package
  /// [env] is the environment of the package
  Future<CRSResponse<CRSArchive>> getArchiveWithVersion(
      String packageName, String version,
      {String? language, Map<String, dynamic>? env});

  /// Turn the server into a file server for a package
  ///
  /// **WARN**: Experimental and Unimplemented API - **DO NOT USE THIS**
  FutureOr setFileServer(String packageName,
      {String? version, String? language, bool cache = false});
}

/// An interface for the core registry system, used by adapters to make requests to retrieve common data
abstract interface class CRSDBController {
  /// The database interface used by the controller
  PrittDatabaseInterface get db;

  /// get the latest version of a package
  /// 
  /// The package name [packageName] can be a plain package name or a scoped package name (e.g. `@scope/package`)
  Future<CRSResponse<PackageVersions>> getLatestPackage(String packageName,
      {String? language, Map<String, dynamic>? env});

  /// get a specific version of a package
  /// 
  /// The package name [packageName] can be a plain package name or a scoped package name (e.g. `@scope/package`)
  Future<CRSResponse<PackageVersions>> getPackageWithVersion(
      String packageName, String version,
      {String? language, Map<String, dynamic>? env});

  /// get all versions of a package from the registry
  /// 
  /// The package name [packageName] can be a plain package name or a scoped package name (e.g. `@scope/package`)
  Future<CRSResponse<Map<Version, PackageVersions>>> getPackages(
      String packageName,
      {String? language,
      Map<String, dynamic>? env});

  /// get all versions of a package from the registry streamed
  /// 
  /// The package name [packageName] can be a plain package name or a scoped package name (e.g. `@scope/package`)
  CRSResponse<Stream<PackageVersions>> getPackagesStream(String packageName,
      {String? language, Map<String, dynamic>? env});

  /// get the package details from the registry
  /// 
  /// The package name [packageName] can be a plain package name or a scoped package name (e.g. `@scope/package`)
  Future<CRSResponse<Package>> getPackageDetails(String packageName,
      {String? language, Map<String, dynamic>? env});

  /// get package contributors and authors
  /// 
  /// The package name [packageName] can be a plain package name or a scoped package name (e.g. `@scope/package`)
  Future<CRSResponse<Map<User, Iterable<Privileges>>>> getPackageContributors(
      String packageName,
      {String? language,
      Map<String, dynamic>? env});
}

abstract class CRSController implements CRSDBController, CRSArchiveController {}

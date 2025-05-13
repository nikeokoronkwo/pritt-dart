// ignore_for_file: constant_identifier_names

import 'dart:typed_data';
import 'package:pritt_server/src/lib/crs/crs.dart';
import 'package:pritt_server/src/lib/crs/db.dart';
import 'package:pritt_server/src/lib/crs/db/schema.dart';
import 'package:pritt_server/src/lib/crs/fs.dart';
import 'package:pritt_server/src/lib/crs/response.dart';
import 'package:pritt_server/src/lib/shared/version.dart';

class CRSArchive {
  final String name;

  final String? contentType;

  final Uint8List data;

  const CRSArchive(this.name, this.contentType, this.data);
  CRSArchive.empty()
      : name = '',
        contentType = null,
        data = Uint8List(0);
}

/// an interface for the core registry system, used by adapters to make requests to retrieve common data
abstract interface class CRSArchiveController {
  /// The object file system interface used by the controller
  CRSRegistryOFSInterface get ofs;

  /// get the archive of a package
  Future<CRSResponse<CRSArchive>> getArchive(String packageName, String version,
      {String? language, Map<String, dynamic>? env});

  /// get the archive of a package
  Future<CRSResponse<CRSArchive>> getArchiveWithVersion(
      String packageName, String version,
      {String? language, Map<String, dynamic>? env});
}

/// An interface for the core registry system, used by adapters to make requests to retrieve common data
abstract interface class CRSDBController {
  /// The database interface used by the controller
  CRSDatabaseInterface get db;

  /// get the latest version of a package
  Future<CRSResponse<PackageVersions>> getLatestPackage(String packageName,
      {String? language, Map<String, dynamic>? env});

  /// get a specific version of a package
  Future<CRSResponse<PackageVersions>> getPackageWithVersion(
      String packageName, String version,
      {String? language, Map<String, dynamic>? env});

  /// get the packages from the registry
  Future<CRSResponse<Map<Version, PackageVersions>>> getPackages(
      String packageName,
      {String? language,
      Map<String, dynamic>? env});

  /// get the package details from the registry
  Future<CRSResponse<Package>> getPackageDetails(String packageName,
      {String? language, Map<String, dynamic>? env});
}

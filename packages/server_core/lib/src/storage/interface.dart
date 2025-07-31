import 'dart:async';
import 'dart:typed_data';

import '../db/interface.dart';

/// This object is an interface for the Object File System used for the Common Core Registry Service
/// and is used to store the packages and their versions.
/// The Object File System is a file system that is used to store the packages and their versions.
///
/// This should only be used for accessing the raw packages. Data can be accessed via the [PrittDatabaseInterface] interface.
abstract interface class PrittStorageInterface<T> {
  T get pkgBucket;

  T get publishingBucket;

  T get adapterBucket;

  /// Add a new package file to the CRS OFS (package bucket)
  ///
  /// [path] represents the path of the new file, to which [data] is stored as bytes.
  FutureOr createPackage(
    String path,
    Uint8List data,
    String sha, {
    String? contentType,
    Map<String, String>? metadata,
    bool private = false,
  });

  /// Remove a package file located at [path] from the CRS OFS
  FutureOr removePackage(String path);

  /// Update the package file at [path] with the new [data]
  FutureOr updatePackage(String path, Uint8List data);

  /// Copy the package file from [from] to [to]
  FutureOr copyPackage(String from, String to);

  /// List the package file in the given [path]
  FutureOr<CRSFile?> findPackage(String path);

  /// List all the package files which satisfy the given requirement
  FutureOr<List<CRSFile>> listPackagesWhere(bool Function(String path) where);

  /// List all the package files in the OFS
  FutureOr<List<CRSFile>> listAllPackages();

  /// Get the package file at [path]
  FutureOr<CRSFileOutputStream> getPackage(String path);

  /// Check if the publishing archive file at a given path exists
  FutureOr<bool> pubArchiveExists(String path);

  /// Get publishing archive
  FutureOr<CRSFileOutputStream> getPubArchive(String path);

  /// Add a publishing archive to the pub archive bucket
  FutureOr createPubArchive(
    String path,
    Uint8List data, {
    String? contentType,
    Map<String, String>? metadata,
  });

  /// Remove a publishing archive file located at [path] from the CRS OFS
  FutureOr removePubArchive(String path);

  /// Move a publishing archive to a package archive
  FutureOr movePubArchiveToPackage(String from, String to);

  /// Create a new URL for the storage system
  FutureOr<Uri> createPubEndpointUrl(String path, {required String pubId});
}

class CRSFile {
  final String path;
  final DateTime? lastModified;
  final int size;

  const CRSFile({
    required this.path,
    required this.lastModified,
    required this.size,
  });
}

/// A CRS File Output Stream
class CRSFileOutputStream {
  /// The path to the file
  final String path;

  /// The data to be written to the file
  final Uint8List data;

  /// The metadata of the file
  final Map<String, String> metadata;

  /// The content type of the file
  final String? contentType;

  /// The size of the file
  final int size;

  /// The hash of the file
  final String hash;

  /// The signature of the file
  final String? signature;

  /// The integrity of the file
  final String? integrity;

  CRSFileOutputStream({
    required this.path,
    required this.data,
    required this.metadata,
    this.contentType,
    required this.size,
    required this.hash,
    this.signature,
    this.integrity,
  });
}

import 'dart:async';
import 'dart:typed_data';

import 'db.dart';

/// This object is an interface for the Object File System used for the Common Core Registry Service
/// and is used to store the packages and their versions.
/// The Object File System is a file system that is used to store the packages and their versions.
///
/// This should only be used for accessing the raw packages. Data can be accessed via the [CRSDatabaseInterface] interface.
abstract interface class CRSRegistryOFSInterface {
  /// Add a new file to the CRS OFS
  ///
  /// [path] represents the path of the new file, to which [data] is stored as bytes.
  FutureOr create(String path, Uint8List data, String sha,
      {String? contentType, Map<String, String>? metadata});

  /// Remove a file located at [path] from the CRS OFS
  FutureOr remove(String path);

  /// Update the file at [path] with the new [data]
  FutureOr update(String path, Uint8List data);

  /// Copy the file from [from] to [to]
  FutureOr copy(String from, String to);

  /// List the file in the given [path]
  FutureOr<CRSFile?> find(String path);

  /// List all the files which satisfy the given requirement
  FutureOr<List<CRSFile>> listWhere(bool Function(String path) where);

  /// List all the files in the OFS
  FutureOr<List<CRSFile>> listAll();

  /// Get the file at [path]
  FutureOr<CRSFileOutputStream> get(String path);
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
  final String contentType;

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
    required this.contentType,
    required this.size,
    required this.hash,
    this.signature,
    this.integrity,
  });
}

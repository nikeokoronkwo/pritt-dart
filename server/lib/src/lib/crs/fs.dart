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
  FutureOr create(String path, Uint8List data, String sha);

  /// Remove a file located at [path] from the CRS OFS
  FutureOr remove(String path);

  /// Update the file at [path] with the new [data]
  FutureOr update(String path, Uint8List data);

  /// Copy the file from [from] to [to]
  FutureOr copy(String from, String to);

  /// List all the files in the given [path]
  FutureOr list(String path);

  /// List all the files which satisfy the given requirement
  FutureOr listWhere(bool Function(String path) where);

  /// List all the files in the OFS
  FutureOr listAll();
}

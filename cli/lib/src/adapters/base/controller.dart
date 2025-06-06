import 'dart:async';

import 'package:pritt_cli/src/utils/typedefs.dart';

import 'package:pritt_common/interface.dart' as common;

/// A minimized version of [PrittLocalController] without awareness of context or config
abstract interface class PrittLocalConfigUnawareController {
  /// Given the configuration file specified by a handler, read the configuration file at the given [directory]
  ///
  /// Throws a [ControllerException] if the configuration file is not specified
  FutureOr<String> readConfigFile(String directory);

  /// Similar to [readConfigFile], but reads the file synchronously
  String readConfigFileSync(String directory);

  /// Get the current user, and return the user object
  ///
  /// TODO: Cache consistent calls
  FutureOr<User> getCurrentUser();

  /// Get the current user as an [common.Author] object
  ///
  /// TODO: Cache consistent calls
  FutureOr<common.Author> getCurrentAuthor();

  /// List files in a directory as a [Stream]
  Stream<String> listFilesAt(String directory, {bool deep = false});

  /// List files in a directory synchronously
  List<String> listFilesAtSync(String directory, {bool deep = false});

  /// Read a file at a given path
  Future<String> readFileAt(String path, {String? cwd});

  /// Read a file at a given path synchronously
  String readFileAtSync(String path, {String? cwd});

  /// Checks if a file exists at a given directory
  Future<bool> fileExists(String path, {String? cwd});

  /// Log message
  void log(Object msg);

  /// The name of the configuration file
  String configFileName();

  /// Runs a command, and passes the value of stdout if successful
  Future<String> run(String command,
      {List<String> args = const [], String? directory});
}

/// TODO: Get more functions for configuring
abstract interface class PrittLocalController<T>
    extends PrittLocalConfigUnawareController {
  /// Get the configuration from a project
  FutureOr<T> getConfiguration(String directory);

  /// Set to use package manager commands with hosted
  useHostedPMCommands();

  /// Write to files
  Future<void> writeFileAt(String path, String contents, {String? cwd});

  /// Get the current instance of the URI
  String get instanceUri;
}

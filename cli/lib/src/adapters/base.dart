import 'dart:async';

import 'package:pritt_cli/src/adapters/base/config.dart';
import 'package:pritt_cli/src/adapters/base/workspace.dart';
import 'package:pritt_cli/src/adapters/base/context.dart';
import 'package:pritt_cli/src/adapters/base/controller.dart';
import 'package:pritt_cli/src/ignore.dart';
import 'package:pritt_cli/src/loader.dart';

typedef OnCheckWorkspaceFunc = FutureOr<bool> Function(String workspace);

/// A pritt "handler" (we should probably rename this to something else) is an object used for adding support for various package types
/// They are usually coupled with an adapter
///
/// NOTE: A Workspace might have various handlers (multi-language projects)
///
/// TODO(https://github.com/nikeokoronkwo/pritt-dart/issues/6): Migrate
///
/// TODO: Infer LICENSE
class Handler<T extends Config> {
  /// The name of the handler
  final String name;

  /// The id of the handler
  final String id;

  /// The language of the handler
  final String language;

  /// The name of the package manager
  final PackageManager? packageManager;

  /// The name of the file where configuration data is stored
  final Loader<String, String> config;

  /// The ignore file
  final Loader<IgnoreFiles, String>? ignore;

  String get configFile => config.name;

  String? get ignoreFile => ignore?.name;

  /// Package manager commands

  /// A function to run when the handler is called for getting configuration data about the package
  /// This function is usually run
  ///
  /// This configuration data can contain multiple things, but must contain the following:
  /// - The name of the package
  /// - The version of the package
  /// - The description of the package
  /// - The author of the package
  /// - The license of the package
  ///
  /// Other data can be added, but is not required
  final FutureOr<T> Function(
          String directory, PrittLocalConfigUnawareController controller)
      onGetConfig;

  /// A function to run to get workspace data about the package
  /// This function is usually run when the package is being published, set up, etc
  ///
  /// - The configuration file for the workspace
  /// - The directory of the workspace
  final FutureOr<Workspace<T>> Function(
      String directory, PrittLocalController controller) onGetWorkspace;

  /// A function run to check whether a given workspace is for a given handler
  ///
  /// Defaults to `return await controller.fileExists(this.configFile);`
  final FutureOr<bool> Function(
          String workspace, PrittLocalConfigUnawareController controller)?
      onCheckWorkspace;

  /// A function run to configure a given workspace
  /// This is run to set up a workspace when installing a given package
  final FutureOr Function(PrittContext context, PrittLocalController controller)
      onConfigure;

  final FutureOr<Map<String, dynamic>> Function(
      PrittContext context, PrittLocalController controller)? getEnv;

  /// An enum to represent who should publish a package
  /// Given that the publisher is [PublishManager.pm], then publish commands must be passed to the [packageManager] in order to perform such publishing
  final PublishManager publisher;

  Handler(
      {required this.id,
      required this.name,
      required this.language,
      required this.config,
      this.ignore,
      this.packageManager,
      required this.onGetConfig,
      required this.onGetWorkspace,
      this.onCheckWorkspace,
      required this.onConfigure,
      this.getEnv,
      this.publisher = PublishManager.pritt})
      : assert(
            publisher == PublishManager.pritt ||
                packageManager?.onPublish != null,
            "For the publisher to be the language's package manager, publishing instructions should be passed");
}

enum PublishManager {
  pritt,
  pm;
}

class MultiPackageManagerHandler<T extends Config> extends Handler<T> {
  Map<String, PackageManager> packageManagers;

  MultiPackageManagerHandler(
      {required super.id,
      required super.name,
      required super.language,
      required super.config,
      super.ignore,
      required super.onGetConfig,
      required super.onGetWorkspace,
      super.onCheckWorkspace,
      required super.onConfigure,
      super.publisher,
      super.getEnv,
      this.packageManagers = const {}});

  @override
  PackageManager? get packageManager =>
      throw Exception("Use `packageManagers` instead");
}

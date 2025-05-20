import 'dart:async';

import 'package:pritt_cli/src/plugins/base/config.dart';
import 'package:pritt_cli/src/plugins/base/workspace.dart';
import 'package:pritt_cli/src/plugins/context.dart';
import 'package:pritt_cli/src/plugins/controller.dart';

typedef OnCheckWorkspaceFunc = FutureOr<bool> Function(String workspace);

/// A pritt "handler" (we should probably rename this to something else) is an object used for adding support for various package types
/// They are usually coupled with an adapter
///
/// TODO(https://github.com/nikeokoronkwo/pritt-dart/issues/6): Migrate
class Handler {
  /// The name of the handler
  final String name;

  /// The id of the handler
  final String id;

  /// The language of the handler
  final String language;

  /// The name of the package manager
  final PackageManager? packageManager;

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
  final FutureOr<Config?> Function(String directory, PrittLocalConfigUnawareController controller) onGetConfig;

  /// A function to run to get workspace data about the package
  /// This function is usually run when the package is being published, set up, etc
  /// 
  /// - The configuration file for the workspace
  /// - The directory of the workspace
  final FutureOr<Workspace?> Function(String directory, PrittLocalController controller) onGetWorkspace;

  /// A function run to check whether a given workspace is for a given handler
  final FutureOr<bool> Function(String workspace, PrittLocalController controller) onCheckWorkspace;

  /// A function run to configure a given workspace
  /// This is run to set up a workspace when installing a given package
  final FutureOr Function(PrittContext context, PrittLocalController controller) onConfigure;

  Handler(
      {required this.id,
      required this.name,
      required this.language,
      required this.packageManager,
      required this.onGetConfig,
      required this.onGetWorkspace,
      required this.onCheckWorkspace,
      required this.onConfigure});
}


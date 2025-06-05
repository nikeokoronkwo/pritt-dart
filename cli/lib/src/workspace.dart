import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pritt_cli/src/adapters/base.dart';
import 'package:pritt_cli/src/adapters/base/context.dart';
import 'package:pritt_cli/src/client.dart';
import 'package:pritt_cli/src/config.dart';
import 'package:pritt_cli/src/ignore.dart';
import 'package:pritt_cli/src/project/controller.dart';

import 'package:pritt_cli/src/project/handler_manager.dart';
import 'package:pritt_common/interface.dart';
import 'package:yaml/yaml.dart';

/// A class used to define the basic details for a project, including its [Workspace]
///
/// TODO: Monorepo support
class Project {
  /// Handlers for the current project
  final Iterable<Handler> handlers;
  int? _activeHandlerIndex;

  /// The current directory of the project
  final String directory;

  /// The pritt configuration for the project
  final PrittConfig? config;

  /// The version control system being used
  final VCS vcs;

  /// Files being ignored
  final IgnoreFiles _ignoreFiles;

  /// The handler manager
  final PrittControllerManager _manager;

  Project._(
      {required this.handlers,
      this.vcs = VCS.git,
      required this.config,
      required this.directory,
      IgnoreFiles ignoreFiles = commonlyIgnoredFiles,
      required PrittControllerManager manager})
      :
        // TODO: Add support for multiple handlers
        assert(handlers.length <= 1,
            "Unsupported: Multiple handlers is not supported"),
        _manager = manager,
        _ignoreFiles = ignoreFiles;

  /// configures the project
  Future<void> configure() async {
    for (final handler in handlers) {
      final controller = _manager.makeController(handler);
      final workspace = await handler.onGetWorkspace(directory, controller);
      await handler.onConfigure(PrittContext(workspace: workspace), controller);
    }
  }
}

/// Get the current workspace information for the project being worked on
Future<Project> getWorkspace(String directory,
    {String? config, PrittClient? client}) async {
  final dir = Directory(directory);
  // get basic workspace information
  final HandlerManager manager =
      HandlerManager(directory: directory, apiClient: client);
  final handlers = manager.find(directory);

  // in the meantime...
  // check for the vcs
  final VCS vcs = await getVersionControlSystem(dir);

  // check for the pritt configuration
  final PrittConfig? prittConfig = await readPrittConfig(directory, config);

  // check for a .prittignore
  final List<String> ignoreFiles = const LineSplitter().convert(
      (await File(p.join(directory, '.prittignore')).exists())
          ? await File(p.join(directory, '.prittignore')).readAsString()
          : '')
    ..addAll(commonlyIgnoredFiles);

  final resolvedHandlers = await handlers;
  for (final h in resolvedHandlers) {
    // add ignores
    if (h.ignore != null) {
      final ignoreContents = h.ignore!
          .load(await File(p.join(directory, h.ignoreFile)).readAsString());
      ignoreFiles.addAll(ignoreContents);
    }
  }

  // assemble
  return Project._(
      handlers: await handlers,
      config: prittConfig,
      directory: directory,
      vcs: vcs,
      ignoreFiles: ignoreFiles,
      manager: manager.controllerHandler);
}

Future<PrittConfig?> readPrittConfig(String dir, String? config) async {
  final File configFile = File(config ?? p.join(dir, 'pritt.yaml'));

  if (await configFile.exists()) return null;

  final configContents = await configFile.readAsString();
  return PrittConfig.fromJson(jsonDecode(jsonEncode(loadYaml(configContents))));
}

Future<VCS> getVersionControlSystem(Directory directory) async {
  await for (final entity in directory.list()) {
    if (entity is Directory) {
      switch (p.basename(entity.path)) {
        case '.git':
          return VCS.git;
        case '.svn':
          return VCS.svn;
        case '.hg':
          return VCS.mercurial;
        case '_FOSSIL_':
          return VCS.fossil;
        default:
          continue;
      }
    } else if (entity is File) {
      if (['.fslckout', '.fossil'].contains(p.extension(entity.path))) {
        return VCS.fossil;
      }
    }
  }
  return VCS.other;
}

/// Configure the current project to make use of Pritt
configureWorkspace(String directory) {
  // get the current project workspace

  // get the language of the project

  // check if user is logged in

  // if not logged in,

  // configure for project
}

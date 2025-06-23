import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pritt_common/interface.dart';
import 'package:yaml/yaml.dart';

import 'adapters/base.dart';
import 'adapters/base/context.dart';
import 'adapters/base/workspace.dart';
import 'client.dart';
import 'config.dart';
import 'ignore.dart';
import 'project/controller.dart';
import 'project/handler_manager.dart';

/// A class used to define the basic details for a project, including its [Workspace]
///
/// TODO: Monorepo support
class Project {
  /// Handlers for the current project
  final List<Handler> handlers;

  int? _primaryHandlerIndex;

  Handler get primaryHandler {
    if (_primaryHandlerIndex != null)
      return handlers[_primaryHandlerIndex!];
    else
      throw Exception('No active handler set');
  }

  set primaryHandler(Handler h) {
    _primaryHandlerIndex = handlers.indexOf(h);
  }

  /// Get the README for a project, if any
  (String?, {String? format}) get readme {
    try {
      final file = Directory(directory).listSync().whereType<File>().firstWhere(
          (f) => p.basenameWithoutExtension(f.path).toLowerCase() == 'readme');

      return (
        file.readAsStringSync(),
        format: p.extension(file.path).replaceFirst('.', '')
      );
    } on StateError catch (_) {
      return (null, format: null);
    }
  }

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

  /// get the environment variables.
  /// Returns a map of env for each handler
  ///
  /// NOTE: Primary Handler must be set
  Future<Map<String, dynamic>> getEnv() async {
    final controller = _manager.makeController(primaryHandler);
    final workspace =
        await primaryHandler.onGetWorkspace(directory, controller);
    return await primaryHandler.getEnv
            ?.call(PrittContext(workspace: workspace), controller) ??
        {};
  }

  Future<Workspace> getWorkspace() async {
    final controller = _manager.makeController(primaryHandler);
    return await primaryHandler.onGetWorkspace(directory, controller);
  }

  Future<String> getConfig() async {
    return primaryHandler.config.load(
        await File(p.join(directory, primaryHandler.configFile))
            .readAsString());
  }

  // FIXME: Fix this function
  Stream<File> files() {
    return Directory(directory)
        .list(recursive: true)
        .where((f) {
          if (f is File) {
            return _ignoreFiles.match(f.path);
          } else if (f is Directory) {
            return _ignoreFiles.match(f.path);
          } else {
            return false;
          }
        })
        .where((f) => f is File)
        .map((f) => f as File);
  }

  // FIXME: Fix this function
  List<File> filesSync() {
    return Directory(directory)
        .listSync(recursive: true)
        .where((f) {
          if (f is File) {
            return _ignoreFiles.match(f.path);
          } else if (f is Directory) {
            return _ignoreFiles.match(f.path);
          } else {
            return false;
          }
        })
        .whereType<File>()
        .toList();
  }
}

/// Get the current workspace information for the project being worked on
Future<Project> getProject(String directory,
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
      final ignoreFile = File(p.join(directory, h.ignoreFile));
      if (await ignoreFile.exists()) {
        final ignoreContents = h.ignore!.load(await ignoreFile.readAsString());
        ignoreFiles.addAll(ignoreContents);
      }
    }
  }

  // assemble
  return Project._(
      handlers: (await handlers).toList(),
      config: prittConfig,
      directory: directory,
      vcs: vcs,
      ignoreFiles: ignoreFiles,
      manager: manager.controllerHandler);
}

Future<PrittConfig?> readPrittConfig(String dir, String? config) async {
  final File configFile = File(config ?? p.join(dir, 'pritt.yaml'));

  if (!(await configFile.exists())) return null;

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

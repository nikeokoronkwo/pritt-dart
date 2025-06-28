import '../adapters/base.dart';
import '../adapters/dart.dart';
import '../adapters/npm.dart';
import '../client.dart';
import 'controller.dart';

/// A manager used for managing handlers (aka client adapters) and perform searching for the needed handler
///
/// This is similar to a client adapter registry
// TODO(nikeokoronkwo): Implement worker architecture, https://github.com/nikeokoronkwo/pritt-dart/issues/24
class HandlerManager {
  final List<Handler> _coreHandlers = [npmHandler, dartHandler];

  final PrittControllerManager controllerHandler;

  HandlerManager(
      {int startWorkers = 1,
      int maxWorkers = 4,
      PrittClient? apiClient,
      String? directory})
      : controllerHandler =
            PrittControllerManager(apiClient: apiClient, dir: directory);

  /// Find the adapter for a given project workspace, given its directory
  ///
  /// Adapters will be searched for on a first
  Future<Iterable<Handler>> find(String directory) async {
    // start workers
    final results = await Future.wait(_coreHandlers.map((c) async {
      final controller = controllerHandler.makeConfigUnawareController(c);
      return await (c.onCheckWorkspace?.call(directory, controller) ??
          controller.fileExists(controller.configFileName()));
    }));
    if (!results.any((r) => r)) {
      return [];
    } else {
      final index = results.indexed.where((r) => r.$2).map((r) => r.$1);
      return _coreHandlers.indexed
          .where((h) => index.contains(h.$1))
          .map((h) => h.$2);
    }
  }

  Future<Handler?> findFirst(String directory) async {
    // start workers
    final results = await Future.wait(_coreHandlers.map((c) async {
      final controller = controllerHandler.makeConfigUnawareController(c);
      return await (c.onCheckWorkspace?.call(directory, controller) ??
          controller.fileExists(controller.configFileName()));
    }));
    if (!results.any((r) => r)) {
      return null;
    } else {
      final index = results.indexWhere((r) => r);
      return _coreHandlers[index];
    }
  }
}

/// A worker
class HandlerWorker {}

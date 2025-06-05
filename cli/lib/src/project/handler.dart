import 'package:pritt_cli/src/adapters/base.dart';
import 'package:pritt_cli/src/adapters/dart.dart';
import 'package:pritt_cli/src/adapters/npm.dart';

/// A manager used for managing handlers (aka client adapters) and perform searching for the needed handler
/// 
/// This is similar to a client adapter registry
class HandlerManager {
  final List<Handler> _coreHandlers = [npmHandler, dartHandler];

  /// Find the adapter for a given project workspace, given its directory
  /// 
  /// Adapters will be searched for on a first
  Future<Handler> find(String directory) async {
    throw UnimplementedError();
  }
}

/// A worker 
class HandlerWorker {

}
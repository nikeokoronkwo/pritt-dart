import 'dart:async';

import 'adapter.dart';
import 'adapter_base.dart';
import 'core/dart.dart';
import 'core/npm.dart';

/// An adapter registry implementation
///
/// The adapter registry is responsible for retrieving and controlling adapters in Pritt.
/// It also sources and fetches custom adapters based on its index of
class AdapterRegistry {
  AdapterRegistry._() {
    if (AdapterRegistry.db == null) {
      // initialise db
    }
  }

  /// We need only a single instance of this running (or do we?)
  static CustomAdapterDB? db;

  /// The core adapters
  final List<Adapter> _coreAdapters = [dartAdapter, npmAdapter];

  /// The custom adapters
  Stream<Adapter> get _customAdapters {
    throw UnimplementedError("TODO: Implement 'get adapters'");
  }

  /// Get the total number of adapters available
  Stream<Adapter> get adapters async* {
    for (final adapter in _coreAdapters) {
      yield adapter;
    }
    yield* _customAdapters;
  }

  /// Connects the adapter registry to the given external database, containing information about the adapters
  ///
  /// The registry can connect to a URL, file path, or work on local memory
  ///
  /// If "local" is passed, then the registry uses local memory to handle the registry (this can be used for testing or dev work)
  ///
  /// This function must be called before any other function on this, else an error will be thrown to connect the database first.
  static Future<AdapterRegistry> connect() async {
    return AdapterRegistry._();
  }

  Future disconnect() async {}

  /// Find an adapter given a request
  FutureOr<({Adapter adapter, AdapterResolve resolve})> find(
      AdapterResolveObject obj,
      {bool checkedCore = false}) async {
    await for (final adapter in (checkedCore ? _customAdapters : adapters)) {
      final adapterResolve = adapter.onResolve(obj);
      if (adapterResolve.isResolved) {
        return (adapter: adapter, resolve: adapterResolve);
      }
    }
    throw AdapterException("Could not find adapter");
  }

  /// Find an adapter given a request from the core adapters
  ({Adapter adapter, AdapterResolve resolve})? findInCore(
      AdapterResolveObject obj) {
    for (final adapter in _coreAdapters) {
      final adapterResolve = adapter.onResolve(obj);
      if (adapterResolve.isResolved) {
        return (adapter: adapter, resolve: adapterResolve);
      } else print('Nope: not $adapter: ${adapter.language} - ${adapterResolve}');
    }
    return null;
  }
}

/// An object instance which abstracts access to the external adapter
class CustomAdapterDB {
  /// get an adapter by its id
  Future<Adapter> getAdapterById(String id) async {
    throw UnimplementedError("TODO: Implement getAdapterById");
  }

  /// get a list of adapters that satisfy a given language
  Future<Iterable<Adapter>> getAdaptersByLanguage(String language) async {
    throw UnimplementedError("TODO: Implement getAdaptersByLanguage");
  }
}

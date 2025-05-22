import 'dart:async';

import 'package:pritt_server/src/main/adapter_service/adapter_service.dart';

import 'adapter.dart';
import 'adapter_base.dart';
import 'core/dart.dart';
import 'core/npm.dart';

/// An adapter registry implementation
///
/// The adapter registry is responsible for retrieving and controlling adapters in Pritt.
/// It also sources and fetches custom adapters based on its index of
class AdapterRegistry {
  CustomAdapterService get cas => AdapterRegistry.service!;

  AdapterRegistry._();

  /// We need only a single instance of this running (or do we?)
  static CustomAdapterService? service;

  /// The core adapters
  final List<Adapter> _coreAdapters = [dartAdapter, npmAdapter];

  /// Get the total number of adapters available
  Stream<Adapter> get adapters async* {
    for (final adapter in _coreAdapters) {
      yield adapter;
    }
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

  Future<void> disconnect() async {}

  /// Find an adapter given a request
  Future<({AdapterInterface adapter, AdapterResolveType resolve})> find(
      AdapterResolveObject obj,
      {bool checkedCore = false}) async {
    if (!checkedCore) {
      await for (final adapter in adapters) {
        final adapterResolve = adapter.resolve(obj);
        if (adapterResolve.isResolved) {
          return (adapter: adapter, resolve: adapterResolve);
        }
      }
    }

    // check custom adapters
    final adapter = await cas.findAdapter(obj);
    if (adapter.adapter != null) {
      return (adapter: adapter.adapter!, resolve: adapter.type);
    }

    throw AdapterException("Could not find adapter");
  }

  /// Find an adapter given a request from the core adapters
  ({Adapter adapter, AdapterResolveType resolve})? findInCore(
      AdapterResolveObject obj) {
    for (final adapter in _coreAdapters) {
      final adapterResolve = adapter.resolve(obj);
      if (adapterResolve.isResolved) {
        return (adapter: adapter, resolve: adapterResolve);
      }
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

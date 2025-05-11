class AdapterResolveObject {}

class AdapterResolve {}

class AdapterResult {}

class AdapterException implements Exception {}

/// A base interface shared between adapters
abstract interface class AdapterInterface {
  /// Run an adapter
  Future run();
}

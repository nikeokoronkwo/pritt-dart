import 'adapter.dart';

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
  final List<Adapter> _coreAdapters = [];

  /// Get the total number of adapters available
  List<Adapter> get adapters {
    final _ = _coreAdapters;
    throw UnimplementedError("TODO: Implement 'get adapters'");
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

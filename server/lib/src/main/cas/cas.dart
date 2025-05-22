import 'package:pritt_server/src/main/adapter/adapter_base.dart';
import 'package:pritt_server/src/main/cas/client.dart';
import 'package:pritt_server/src/main/crs/interfaces.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../adapter/adapter_registry.dart';

/// The Custom Adapter Service
///
/// This is an external service that is used for running custom adapters defined in the service
///
/// BEFORE SERVER INIT: Adapters should be loaded into the service, when initialised by the [AdapterRegistry]
class CustomAdapterService implements CASClient {
  // final String url;

  /// Runs the sorter and finds an adapter
  Future<({CustomAdapter? adapter, AdapterResolveType type})> findAdapter(
      AdapterResolveObject obj) {
    // send request to sorter to find adapter

    // receive adapter info back

    // send request to start worker for adapter

    // return WS 

    // TODO: Implement findAdapter
    throw UnimplementedError();
  }
}

class CustomAdapter implements AdapterInterface {
  WebSocketChannel channel;

  CustomAdapter._(this.channel);

  @override
  Future<AdapterResult> run(CRSController crs, AdapterOptions options) {
    // TODO: implement run
    throw UnimplementedError();

  }

  @override
  // TODO: implement language
  String? get language => throw UnimplementedError();
}

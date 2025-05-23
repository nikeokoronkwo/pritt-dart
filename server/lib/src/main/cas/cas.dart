import 'dart:async';

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
  late CRSController crs;

  final completer = Completer();

  CustomAdapter._(this.channel) {
    channel.stream.listen((message) {
      
    });
  }

  @override
  Future<AdapterResult> run(CRSController crs, AdapterOptions options) async {
    crs = crs;

    // using [Completer]
    final _completer = Completer();

    switch (options.resolveType) {
      case AdapterResolveType.meta:
        return await metaRequest(options.toRequestObject(), crs);
      case AdapterResolveType.archive:
        return await metaRetrieve(options.toRequestObject(), crs);
      default:
        throw AdapterException('Unsupported adapter resolve type');
    }

  }

  Future sendRequest() async {
    return;
  }

  @override
  // TODO: implement language
  String? get language => throw UnimplementedError();
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../adapter/adapter/interface.dart';
import '../adapter/adapter/request_options.dart';
import '../adapter/adapter/resolve.dart';
import '../adapter/adapter/result.dart';
import '../adapter/adapter_registry.dart';
import '../base/db/schema.dart';
import '../crs/interfaces.dart';
import 'client.dart';
import 'services/sorter.dart';

/// The Custom Adapter Service
///
/// This is an external service that is used for running custom adapters defined in the service
///
/// BEFORE SERVER INIT: Adapters should be loaded into the service, when initialised by the [AdapterRegistry]
class CustomAdapterService {
  final Client _client;
  Uri url;
  Map<String, Plugin> adapters;

  CustomAdapterService({
    required this.url,
    Client? client,
    required this.adapters,
  }) : _client = client ?? Client();

  static Future<CustomAdapterService> connect(
    Uri uri, {
    List<Plugin> plugins = const [],
    Map<String, Map<String, String>> pluginCodeMap = const {},
  }) async {
    final client = Client();

    final cas = CustomAdapterService(
      url: uri,
      client: client,
      adapters: plugins.asMap().map((k, v) => MapEntry(v.id, v)),
    );

    // load adapters
    await cas._loadAdapters(plugins: plugins, pluginCodeMap: pluginCodeMap);

    return cas;
  }

  // TODO: Can we make the plugin code map typed?
  Future _loadAdapters({
    required List<Plugin> plugins,
    required Map<String, Map<String, String>> pluginCodeMap,
  }) async {
    // process the code
    final pluginBodyMap = [];

    for (final plugin in plugins) {
      final map = pluginCodeMap[plugin.id];
      if (map != null) {
        if (map.length == 1) {
          // default
          pluginBodyMap.add({
            'type': 'default',
            'code': map.values.first,
            'id': plugin.id,
          });
        } else {
          // multiple
          pluginBodyMap.add({
            'type': 'multi',
            'id': plugin.id,
            'code': {
              'resolve': map['plugin_adapter_on'],
              'metaRequest': map['plugin_adapter_meta_req'],
              'archiveRequest': map['plugin_adapter_archive_req'],
            },
          });
        }
      }
    }

    final response = await _client.post(
      url.replace(path: 'start'),
      body: json.encode({'adapters': pluginBodyMap}),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode != 200) {
      throw ClientException('Failed to load adapters: ${response.body}');
    }
  }

  /// Runs the sorter and finds an adapter
  Future<({CustomAdapter? adapter, AdapterResolveType type})> findAdapter(
    AdapterResolveObject obj,
  ) async {
    // send request to sorter to find adapter
    final response = await _client.post(
      url.replace(path: 'find'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({'resolveObject': obj.toJson()}),
    );

    if (response.statusCode != 200) {
      throw ClientException('Failed to find adapter: ${response.body}');
    }

    print(response.body);

    // receive adapter info back
    final body = SorterResponse.fromJson(json.decode(response.body));

    if (!body.success) {
      return (adapter: null, type: AdapterResolveType.none);
    }

    // send request to start worker for adapter
    final wsConn = WebSocketChannel.connect(
      url.replace(path: '/load/${body.workerId}'),
    );

    await wsConn.ready;

    // return WS
    return (adapter: CustomAdapter._(wsConn), type: body.type);
  }
}

class CustomAdapter implements AdapterInterface {
  WebSocketChannel channel;
  late CRSController crs;

  late Completer completer;

  CustomAdapter._(this.channel) {
    channel.stream.listen((event) {
      final msg = json.decode(event) as Map<String, dynamic>;

      // TODO(nikeokoronkwo): Complete Custom Adapter Implementation, https://github.com/nikeokoronkwo/pritt-dart/issues/62
      if (msg.containsKey('message_type')) {
        // actual message to process
        final message = CASMessage.fromJson(msg);
        if (message is CASRequest) {
          // prcess cas request
        } else {
          // complete completer
        }
      }
    });
  }

  void sendRequest() {}

  @override
  Future<AdapterResult> run(CRSController crs, AdapterOptions options) async {
    crs = crs;
    completer = Completer();

    // using [Completer]
    // final _completer = Completer();

    // switch (options.resolveType) {
    //   case AdapterResolveType.meta:
    //     return await metaRequest(options.toRequestObject(), crs);
    //   case AdapterResolveType.archive:
    //     return await metaRetrieve(options.toRequestObject(), crs);
    //   default:
    //     throw AdapterException('Unsupported adapter resolve type');
    // }
    throw UnimplementedError();
  }

  @override
  // TODO: implement language
  String? get language => throw UnimplementedError();
}

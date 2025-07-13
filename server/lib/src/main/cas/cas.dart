import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chunked_stream/chunked_stream.dart';
import 'package:http/http.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as rpc;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../adapter/adapter/exception.dart';
import '../adapter/adapter/interface.dart';
import '../adapter/adapter/request_options.dart';
import '../adapter/adapter/resolve.dart';
import '../adapter/adapter_registry.dart';
import '../base/db/schema.dart';
import '../crs/interfaces.dart';
import '../crs/response.dart';
import 'result.dart';
import 'services/sorter.dart';
import 'types/messages.dart';

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

extension ParamAsJson on rpc.Parameters {
  Map<String, dynamic> get asJson => asMap as Map<String, dynamic>;
}

class CustomAdapter implements AdapterInterface {
  final Map<String, Stream<List<int>>> _cachedArchives = {};
  WebSocketChannel channel;
  CRSController? crs;

  late Completer completer;
  late final rpc.Peer _peer;

  CustomAdapter._(this.channel) {
    _peer = rpc.Peer(channel.cast<String>());

    // register methods on peer
    _registerCommands();

    unawaited(_peer.listen());
  }

  void _registerCommands() {
    _peer.registerMethod('getLatestPackage', (rpc.Parameters params) async {
      final request = GetLatestPackageRequest.fromJson(params.asJson);

      final resp = await crs!.getLatestPackage(
        request.name,
        language: request.options?.language,
        env: request.options?.env,
      );

      switch (resp) {
        case CRSErrorResponse(error: final e):
          throw rpc.RpcException(RpcCode.unsuccessfulRequest, e);
        case CRSSuccessResponse(body: final body):
          return GetLatestPackageResponse(package: body);
      }
    });
    _peer.registerMethod('getPackageWithVersion', (
      rpc.Parameters params,
    ) async {
      final request = GetPackageWithVersionRequest.fromJson(params.asJson);

      final resp = await crs!.getPackageWithVersion(
        request.name,
        request.version,
        language: request.options?.language,
        env: request.options?.env,
      );

      switch (resp) {
        case CRSErrorResponse(error: final e):
          throw rpc.RpcException(RpcCode.unsuccessfulRequest, e);
        case CRSSuccessResponse(body: final body):
          return GetPackageWithVersionResponse(package: body);
      }
    });
    _peer.registerMethod('getPackages', (rpc.Parameters params) async {
      final request = GetPackagesRequest.fromJson(params.asJson);

      final resp = await crs!.getPackages(
        request.name,
        language: request.options?.language,
        env: request.options?.env,
      );

      switch (resp) {
        case CRSErrorResponse(error: final e):
          throw rpc.RpcException(RpcCode.unsuccessfulRequest, e);
        case CRSSuccessResponse(body: final body):
          return GetPackagesResponse(
            packageVersions: body.map((k, v) => MapEntry(k.toString(), v)),
          );
      }
    });
    _peer.registerMethod('getPackageDetails', (rpc.Parameters params) async {
      final request = GetPackageDetailsRequest.fromJson(params.asJson);

      final resp = await crs!.getPackageDetails(
        request.name,
        language: request.options?.language,
        env: request.options?.env,
      );

      switch (resp) {
        case CRSErrorResponse(error: final e):
          throw rpc.RpcException(RpcCode.unsuccessfulRequest, e);
        case CRSSuccessResponse(body: final body):
          return GetPackageDetailsResponse(package: body);
      }
    });
    _peer.registerMethod('getPackageContributors', (
      rpc.Parameters params,
    ) async {
      final request = GetPackageContributorsRequest.fromJson(params.asJson);

      final resp = await crs!.getPackageContributors(
        request.name,
        language: request.options?.language,
        env: request.options?.env,
      );

      switch (resp) {
        case CRSErrorResponse(error: final e):
          throw rpc.RpcException(RpcCode.unsuccessfulRequest, e);
        case CRSSuccessResponse(body: final body):
          return GetPackageContributorsResponse(
            contributors: body.entries
                .map(
                  (entry) => UserEntry(
                    user: entry.key,
                    privileges: entry.value.toList(),
                  ),
                )
                .toList(),
          );
      }
    });
    _peer.registerMethod('getArchiveWithVersion', (
      rpc.Parameters params,
    ) async {
      final request = GetArchiveWithVersionRequest.fromJson(params.asJson);

      final resp = await crs!.getArchiveWithVersion(
        request.name,
        request.version,
        language: request.language,
      );

      switch (resp) {
        case CRSErrorResponse(error: final e):
          throw rpc.RpcException(RpcCode.unsuccessfulRequest, e);
        case CRSSuccessResponse(body: final body):
          _cachedArchives[body.name] = body.data;
          return await GetArchiveWithVersionResponse.fromArchive(body);
      }
    });
    _peer.registerMethod('getRawArchiveWithVersion', (
      rpc.Parameters params,
    ) async {
      final request = GetArchiveWithVersionRequest.fromJson(params.asJson);

      final resp = await crs!.getArchiveWithVersion(
        request.name,
        request.version,
        language: request.language,
      );

      switch (resp) {
        case CRSErrorResponse(error: final e):
          throw rpc.RpcException(RpcCode.unsuccessfulRequest, e);
        case CRSSuccessResponse(body: final body):
          return await GetRawArchiveWithVersionResponse.fromArchive(body);
      }
    });
  }

  @override
  Future<CustomAdapterResult> run(
    CRSController crs,
    AdapterOptions options,
  ) async {
    crs = crs;
    completer = Completer();

    try {
      switch (options.resolveType) {
        case AdapterResolveType.meta:
          final response = await _peer.sendRequest(
            'metaRequest',
            options.toRequestObject().toJson(),
          );
          return CustomAdapterMetaResult.fromJson(response);
        case AdapterResolveType.archive:
          final response = await _peer.sendRequest(
            'metaRetrieve',
            options.toRequestObject().toJson(),
          );
          final archiveResponse = CustomAdapterArchiveResult.fromJson(response);
          archiveResponse.archive ??= await readByteStream(
            _cachedArchives[archiveResponse.archiveTarget] ??
                const Stream.empty(),
          );
          return archiveResponse;
        default:
          throw AdapterException('Unsupported adapter resolve type');
      }
    } on AdapterException {
      rethrow;
    } on rpc.RpcException catch (e) {
      // error result
      return CustomAdapterErrorResult(e.data, message: e.message);
    }
  }

  Future<void> close() async {
    _peer.sendNotification('complete');
    await _peer.close();
  }

  @override
  // TODO: implement language
  String? get language => throw UnimplementedError();
}

extension type RpcCode._(int _) implements int {
  static RpcCode unsuccessfulRequest = RpcCode._(1);
}

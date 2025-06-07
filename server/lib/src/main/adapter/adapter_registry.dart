import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:pritt_server/src/main/adapter/adapter/exception.dart';
import 'package:pritt_server/src/main/adapter/adapter/interface.dart';
import 'package:pritt_server/src/main/adapter/adapter/resolve.dart';
import 'package:pritt_server/src/main/base/db/schema.dart';
import 'package:pritt_server/src/main/base/storage/interface.dart';
import 'package:pritt_server/src/main/cas/cas.dart';
import 'package:pritt_server/src/main/base/db.dart';
import 'package:pritt_server/src/main/base/db/interface.dart';
import 'package:pritt_server/src/main/cas/db.dart';

import 'adapter.dart';
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
  /// The registry can connect to:
  /// - local memory
  /// - a URL: [Uri],
  /// - file path: [Uri.file] or [String],
  /// - a production DB instance conforming to [PrittAdapterDatabaseInterface], usually being [PrittDatabase],
  ///
  /// If "local" is passed, then the registry uses local memory to handle the registry (this can be used for testing or dev work)
  ///
  /// This function must be called before any other function on this, else an error will be thrown to connect the database first.
  static Future<AdapterRegistry> connect(
      {Object? db, PrittStorageInterface? storage, Uri? runnerUri}) async {
    if (service != null) {
      return AdapterRegistry._();
    }

    runnerUri ??= Uri.parse(
        'http://localhost:${String.fromEnvironment('PRITT_RUNNER_PORT', defaultValue: '8000')}');

    final PrittAdapterDatabaseInterface databaseInterface;

    if (db is! PrittAdapterWithBlobDatabaseInterface && storage != null) {
      throw Exception(
          "If db cannot contain storage (i.e db is not PrittAdapterWithBlobDatabaseInterface), storage must not be null");
    }

    // check type
    if (db is String) {
      // sqlite database at path
      if (db == 'local') {
        // in memory sqlite db
        databaseInterface = await CASLocalDatabase.connect(local: true);
      } else {
        if (p.extension(db) != '.db') {
          throw Exception("Cannot connect to non-sqlite3 Registry DB");
        }
        databaseInterface = await CASLocalDatabase.connect(url: db);
      }
    } else if (db is PrittAdapterDatabaseInterface) {
      databaseInterface = db;
    } else if (db is Uri) {
      // sqlite database at path
      if (p.extension(db.toFilePath()) != '.db') {
        throw Exception("Cannot connect to non-sqlite3 Registry DB");
      }

      databaseInterface = await CASLocalDatabase.connect(url: db.toString());
    } else {
      throw AssertionError(
          'Unsupported type: db must be String, Uri or an implementation of PrittAdapterDatabaseInterface');
    }

    // before starting...
    // get all adapters and their code
    final plugins = (await databaseInterface.getPlugins()).toList();

    final Map<String, Map<String, String>> pluginMap = {};

    for (final plugin in plugins) {
      if (db is PrittAdapterWithBlobDatabaseInterface) {
        pluginMap[plugin.id] = await db.getPluginCode(plugin.id);
      } else {
        // open tarball
        final tarballOfPluginResult =
            await storage!.get(plugin.archive.toFilePath());
        final tarballOfPlugin = TarDecoder()
            .decodeBytes(GZipDecoder().decodeBytes(tarballOfPluginResult.data));

        // get the files
        final files = <String, String>{};
        final List<String> approvedNames = switch (plugin.archiveType) {
          // multiple files =>
          //  plugin_meta.[min].js,
          //  plugin_adapter_on.[min].js,
          //  plugin_adapter_meta_req.[min].js, plugin_adapter_archive_req.[min].js,
          //  plugin_handler_on.[min].js
          PluginArchiveType.multi => [
              'plugin_meta.js',
              'plugin_adapter_on.js',
              'plugin_adapter_meta_req.js',
              'plugin_adapter_archive_req.js',
              'plugin_handler_on.js'
            ],
          // single file => plugin.[min].js
          PluginArchiveType.single => ['plugin.js'],
        };

        // while (await tarballOfPlugin.moveNext()) {
        //   if (approvedNames.contains(tarballOfPlugin.current.name)) {
        //     files[p.basenameWithoutExtension(tarballOfPlugin.current.name)] =
        //         (await tarballOfPlugin.current.contents
        //             .transform(utf8.decoder)
        //             .first);
        //   }
        //   // check if files are complete
        //   if (files.length >= approvedNames.length) break;
        // }
        for (final tarballFile in tarballOfPlugin) {
          if (tarballFile.isFile) {
            if (approvedNames.contains(tarballFile.name)) {
              files[p.basenameWithoutExtension(tarballFile.name)] =
                  utf8.decode(tarballFile.content as List<int>);
            }
          }

          if (files.length >= approvedNames.length) break;
        }

        pluginMap[plugin.id] = files;
      }
    }

    // load
    service = await CustomAdapterService.connect(runnerUri,
        plugins: plugins, pluginCodeMap: pluginMap);

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

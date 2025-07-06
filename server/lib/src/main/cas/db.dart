import 'dart:async';

import '../base/db/interface.dart';
import '../base/db/schema.dart';

class CASLocalDatabase implements PrittAdapterDatabaseInterface {
  CASLocalDatabase._();

  static Future<CASLocalDatabase> connect({
    String? url,
    bool local = false,
  }) async {
    assert(
      local || url != null,
      "Either sqlite db is local or uri must be passed",
    );

    return CASLocalDatabase._();
  }

  @override
  FutureOr<Plugin> getPlugin(String id) {
    // TODO: implement getPlugin
    throw UnimplementedError();
  }

  @override
  FutureOr<Iterable<Plugin>> getPlugins() {
    // TODO: implement getPlugins
    throw UnimplementedError();
  }

  @override
  FutureOr<Iterable<Plugin>> getPluginsByLanguage(String language) {
    // TODO: implement getPluginsByLanguage
    throw UnimplementedError();
  }

  @override
  FutureOr<Iterable<Plugin>> getPluginsForLanguages(Set<String> languages) {
    // TODO: implement getPluginsForLanguages
    throw UnimplementedError();
  }
}

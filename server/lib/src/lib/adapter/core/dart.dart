import 'package:pritt_server/src/lib/adapter/adapter.dart';
import 'package:pritt_server/src/lib/adapter/adapter_base.dart';

final dartAdapter = Adapter(
    id: 'dart',
    language: 'dart',
    onResolve: (resolve) {
      if (resolve.userAgent.name == 'Dart pub') {
        if (resolve.path.startsWith('/api/packages')) {
          return AdapterResolve.meta;
        } else if (resolve.path.startsWith('/api/archives')) {
          return AdapterResolve.archive;
        }
      }
      return AdapterResolve.none;
    },
    request: request,
    retrieve: retrieve,
    returnFn: returnFn);

import 'package:pritt_server/src/lib/adapter/adapter.dart';
import 'package:pritt_server/src/lib/adapter/adapter_base.dart';

final pyAdapter = Adapter(
    id: 'python',
    language: 'python',
    onResolve: (resolve) {
      if (resolve.userAgent.name == 'pip') {
        return AdapterResolve.meta;
      }
      return AdapterResolve.none;
    },
    request: (obj, crs) {
      
    },
    retrieve: retrieve);

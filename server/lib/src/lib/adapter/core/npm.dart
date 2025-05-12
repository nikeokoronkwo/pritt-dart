import 'package:pritt_server/src/lib/adapter/adapter.dart';
import 'package:pritt_server/src/lib/adapter/adapter_base.dart';
import 'package:pritt_server/src/utils/extensions.dart';

final npmAdapter = Adapter(
    id: 'npm',
    language: 'javascript',
    onResolve: (resolve) {
      if (resolve.userAgent.toString().containsAllOf(['npm', 'node'])) {
        // TODO: When is it archive?
        return AdapterResolve.meta;
      }
      return AdapterResolve.none;
    },
    request: request,
    retrieve: retrieve,
    returnFn: returnFn);

class NpmUserAgentInfo {}

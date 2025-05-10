import 'adapter_base.dart';

import '../crs/crs.dart';

typedef AdapterResolveFn = AdapterResolve Function(AdapterResolveObject);

typedef AdapterRequestFn = CRSRequest Function(AdapterResolveObject);

typedef AdapterRetrieveFn = CRSRequest Function(AdapterResolveObject);

typedef AdapterReturnFn = AdapterResult Function(CRSResponse);

/// An adapter implementation
///
/// An adapter contains the logic used for making Pritt "adapt" to different registry requests to model such registries
/// Adapters make such processes modular by being able to shape
class Adapter implements AdapterInterface {
  /// The identifier, or name of the adapter
  String id;

  /// The name of the language used for the adapter if any
  ///
  /// Not all adapters may have associated languages. This is here to make creating [CRSRequest] types much easier
  String? language;

  /// The function called upon resolving of the
  AdapterResolveFn _resolve;

  /// The function called when a request is delegated to the given adapter
  ///
  /// The function return is sent to the Core Registry Service
  AdapterRequestFn onRequest;

  /// Similar to [Adapter.onRequest], but used
  AdapterRetrieveFn onRetrieve;

  /// The function called upon return of package info from CRS to the requested service.
  ///
  /// This can be used to restructure the Common Core Registry Service Package Type to the desired return type for the project
  AdapterReturnFn onReturn;

  Adapter({
    required this.id,
    this.language,
    required AdapterResolveFn resolve,
    required AdapterRequestFn request,
    required AdapterRetrieveFn retrieve,
    required AdapterReturnFn returnFn,
  })  : _resolve = resolve,
        onRequest = request,
        onRetrieve = retrieve,
        onReturn = returnFn;
        
          @override
          Future run() {
            // TODO: implement run
            throw UnimplementedError();
          }
}

import 'adapter_base.dart';

import '../crs/crs.dart';

import 'adapter_registry.dart';

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
  final String id;

  /// The language used for the adapter if any
  ///
  /// Not all adapters may have associated languages. This is here to make creating [CRSRequest] types much easier
  final String? language;

  /// The function called upon resolving of the adapter request.
  ///
  /// This is used to sort out which adapter is suited for the given request.
  /// This method is usually used by the [AdapterRegistry] via an [AdapterResolveObject]
  final AdapterResolveFn onResolve;

  /// The function called when a request is delegated to the given adapter.
  ///
  /// The function return is sent to the Core Registry Service as a [CRSRequest] type
  final AdapterRequestFn onRequest;

  /// Similar to [Adapter.onRequest], but used for archive requests
  final AdapterRetrieveFn onRetrieve;

  /// The function called upon return of package info from CRS to the requested service.
  ///
  /// This can be used to restructure the Common Core Registry Service Package Type to the desired return type for the project
  final AdapterReturnFn onReturn;

  const Adapter({
    required this.id,
    this.language,
    required this.onResolve,
    required AdapterRequestFn request,
    required AdapterRetrieveFn retrieve,
    required AdapterReturnFn returnFn,
  })  : onRequest = request,
        onRetrieve = retrieve,
        onReturn = returnFn;

  @override
  Future run() {
    // TODO: implement run
    throw UnimplementedError();
  }
}

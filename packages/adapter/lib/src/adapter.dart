import 'dart:async';

import 'package:pritt_server_core/pritt_server_core.dart';
import 'adapter/exception.dart';
import 'adapter/interface.dart';
import 'adapter/request_options.dart';
import 'adapter/resolve.dart';
import 'adapter/result.dart';
import 'adapter_registry.dart';

typedef AdapterResolveFn = AdapterResolveType Function(AdapterResolveObject);

typedef AdapterRequestFn =
    FutureOr<CoreAdapterResult> Function(AdapterRequestObject, CRSDBController);

typedef AdapterRetrieveFn =
    FutureOr<CoreAdapterResult> Function(
      AdapterRequestObject,
      CRSArchiveController,
    );

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
  @override
  final String? language;

  /// The function called upon resolving of the adapter request.
  ///
  /// This is used to sort out which adapter is suited for the given request.
  /// This method is usually used by the [AdapterRegistry] via an [AdapterResolveObject]
  final AdapterResolveFn resolve;

  /// The function called when a request is delegated to the given adapter.
  ///
  /// The function makes use of a [CRSController] to make requests to the Common Core Registry Service
  /// and returns a [CoreAdapterResult] object.
  final AdapterRequestFn metaRequest;

  /// Similar to [Adapter.metaRequest], but used for archive requests
  final AdapterRetrieveFn archiveRequest;

  const Adapter({
    required this.id,
    this.language,
    required this.resolve,
    required AdapterRequestFn request,
    required AdapterRetrieveFn retrieve,
  }) : metaRequest = request,
       archiveRequest = retrieve;

  @override
  Future<CoreAdapterResult> run(
    CRSController crs,
    AdapterOptions options,
  ) async {
    // run the adapter
    switch (options.resolveType) {
      case AdapterResolveType.meta:
        return await metaRequest(options.toRequestObject(), crs);
      case AdapterResolveType.archive:
        return await archiveRequest(options.toRequestObject(), crs);
      default:
        throw AdapterException('Unsupported adapter resolve type');
    }
  }
}

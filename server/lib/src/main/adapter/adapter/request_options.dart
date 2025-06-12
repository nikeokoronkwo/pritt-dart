// ignore_for_file: constant_identifier_names

import 'resolve.dart';

class AdapterOptions {
  final AdapterResolveObject resolveObject;
  final AdapterResolveType resolveType;

  const AdapterOptions({
    required this.resolveObject,
    required this.resolveType,
  });

  /// generate an [AdapterRequestObject] from the current options
  AdapterRequestObject toRequestObject() {
    return AdapterRequestObject(
      resolveObject: resolveObject,
      env: resolveObject.meta,
      resolveType: resolveType,
    );
  }
}

class AdapterRequestObject {
  AdapterResolveObject resolveObject;

  Map<String, dynamic> env;

  AdapterResolveType resolveType;

  AdapterRequestObject({
    required this.resolveObject,
    Map<String, dynamic>? env,
    required this.resolveType,
  }) : env = env ?? resolveObject.meta;
}

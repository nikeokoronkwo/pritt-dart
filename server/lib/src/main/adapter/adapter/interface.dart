// ignore_for_file: constant_identifier_names

import 'dart:async';

import '../../crs/interfaces.dart';
import 'adapter_base_result.dart';
import 'request_options.dart';
import 'result.dart';

/// A base interface shared between adapters
abstract interface class AdapterInterface {
  String? get language;

  /// Run an adapter
  FutureOr<AdapterBaseResult> run(CRSController crs, AdapterOptions options);
}

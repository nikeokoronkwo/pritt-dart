// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:pritt_server_core/pritt_server_core.dart';

import 'base_result.dart';
import 'request_options.dart';

/// A base interface shared between adapters
abstract interface class AdapterInterface {
  String? get language;

  /// Run an adapter
  FutureOr<AdapterBaseResult> run(CRSController crs, AdapterOptions options);
}

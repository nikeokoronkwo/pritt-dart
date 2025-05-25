// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:pritt_server/src/main/adapter/adapter/request_options.dart';
import 'package:pritt_server/src/main/adapter/adapter/result.dart';
import 'package:pritt_server/src/main/crs/interfaces.dart';

/// A base interface shared between adapters
abstract interface class AdapterInterface {
  String? get language;

  /// Run an adapter
  FutureOr<AdapterResult> run(CRSController crs, AdapterOptions options);
}

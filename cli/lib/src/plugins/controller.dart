import 'dart:async';

import 'package:pritt_cli/src/plugins/base/config.dart';

abstract interface class PrittLocalConfigUnawareController {

}

abstract interface class PrittLocalController extends PrittLocalConfigUnawareController {
  /// Get the configuration from a project
  FutureOr<T> getConfiguration<T extends Config>(String directory);
}
import 'dart:async';


import '../cli/base.dart';

class UnpackCommand extends PrittCommand {
  @override
  String name = "unpack";

  @override
  String description =
      "Get a package locally and make modifications to the package";

  @override
  FutureOr? run() {}
}

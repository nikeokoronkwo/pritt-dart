import 'dart:async';


import '../cli/base.dart';

class YankCommand extends PrittCommand {
  @override
  String name = "yank";

  @override
  String description = "Yank ('remove') a package from Pritt";

  @override
  FutureOr? run() {}
}

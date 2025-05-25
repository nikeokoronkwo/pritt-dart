import 'dart:async';

import 'package:args/command_runner.dart';

class PublishAdapterCommand extends Command {
  @override
  String get name => "adapter";

  @override
  String get description => "Publish an adapter to Pritt";

  @override
  FutureOr? run() {}
}

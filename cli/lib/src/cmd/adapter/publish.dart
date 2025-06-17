import 'package:args/command_runner.dart';

class AdapterPublishCommand extends Command {
  @override
  String get name => "publish";

  @override
  String get description => "Publish an adapter to Pritt";
}

import 'package:args/command_runner.dart';

class AdapterUnpackCommand extends Command {
  @override
  String get name => "unpack";

  @override
  String get description => "Downloads an adapter from Pritt to use in-place";
}

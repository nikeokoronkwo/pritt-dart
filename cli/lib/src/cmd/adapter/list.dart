import 'package:args/command_runner.dart';

class AdapterListCommand extends Command {
  @override
  String name = "list";

  @override
  // TODO: implement description
  String get description =>
      "List all the adapters at the current pritt endpoint";
}

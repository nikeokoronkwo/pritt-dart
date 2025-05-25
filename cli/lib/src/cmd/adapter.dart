import 'package:args/command_runner.dart';
import 'package:pritt_cli/src/cmd/adapter/list.dart';

class AdapterCommand extends Command {
  @override
  String name = "adapter";

  @override
  String description = "Handle and publish custom adapters to Pritt";

  AdapterCommand() {
    addSubcommand(AdapterListCommand());
  }
}

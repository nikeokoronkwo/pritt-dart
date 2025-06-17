import 'package:args/command_runner.dart';
import 'adapter/list.dart';
import 'adapter/publish.dart';
import 'adapter/unpack.dart';

class AdapterCommand extends Command {
  @override
  String name = "adapter";

  @override
  String description = "Handle and publish custom adapters to Pritt";

  AdapterCommand() {
    addSubcommand(AdapterListCommand());
    addSubcommand(AdapterUnpackCommand());
    addSubcommand(AdapterPublishCommand());
  }
}

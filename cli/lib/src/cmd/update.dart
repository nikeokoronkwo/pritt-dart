import 'package:args/command_runner.dart';

class UpdateCommand extends Command {
  @override
  String name = "update";

  @override
  String description = "Updates the Pritt CLI";

  UpdateCommand() {
    argParser.addFlag(
      'auto',
      negatable: false,
      help: "Configure Pritt to auto-update whenever you log into shell",
    );
  }
}

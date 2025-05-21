

import 'package:args/command_runner.dart';

class PublishPackageCommand extends Command {
  @override
  String get name => "package";

  @override
  String get description => "Publish a package to Pritt";
}
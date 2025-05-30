import 'package:args/command_runner.dart';

class PackagePublishCommand extends Command {
  @override
  String get name => "publish";

  @override
  String get description => "Publish a package to Pritt";
}

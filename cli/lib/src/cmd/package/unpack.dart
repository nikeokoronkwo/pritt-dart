import 'package:args/command_runner.dart';

class PackageUnpackCommand extends Command {
  @override
  String get name => "unpack";

  @override
  String get description => "Downloads a package from Pritt to use in-place";
}

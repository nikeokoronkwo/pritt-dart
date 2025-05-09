

import '../../cli/base.dart';

class PackageCurrentCommand extends PrittCommand {
  @override 
  String name = "current";

  @override
  String description = "Get information about the current package if on pritt";

  PackageCurrentCommand() {
    argParser
      .addOption('output', abbr: 'o', help: 'Write as a JSON output to a file', valueHelp: 'file');
  }
}


import '../../cli/base.dart';

class PackageListCommand extends PrittCommand {
  @override 
  String name = "list";

  @override
  String description = "List all packages created or co-authored by user";

  PackageListCommand() {
    argParser
      ..addOption('language', abbr: 'l', help: 'Filter by language')
      ..addOption('output', abbr: 'o', help: 'Write as a JSON output to a file', valueHelp: 'file');
  }
}
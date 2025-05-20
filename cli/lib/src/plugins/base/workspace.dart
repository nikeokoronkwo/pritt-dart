
import 'package:pritt_cli/src/plugins/base/config.dart';

class Workspace {
  Config config;
  String directory;
  String name;
  String? language;
  PackageManager? packageManager;

  Workspace({
    required this.config,
    required this.directory,
    required this.name,
    this.language,
    this.packageManager,
  });
}

class PackageWorkspace extends Workspace {

}

/// TODO: This is a stub for a future feature, not used at the moment
class MonorepoWorkspace extends Workspace {

}

/// TODO: Add better support for adding, removing packages
/// TODO: Add support for (maybe publishing) packages
class PackageManager {
  String name;
  List<String> args;
  
  List<String> Function(PackageInformation info) onAdd;
  List<String> Function(PackageInformation info) onRemove;

  PackageManager({
    required this.name, 
    List<String>? args,
    required this.onAdd,
    required this.onRemove
  }) : args = args ?? [name];
}

class PackageInformation {
  String name;
  String version;
  PackageType type;
}

enum PackageType {
  normal, 
  dev,
  peer, 
  optional, 
  other
}
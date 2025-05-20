
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


class PackageManager {
  String name;

  PackageManager({required this.name});
}

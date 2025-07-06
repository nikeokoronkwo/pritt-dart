import 'dart:convert';

import 'package:pritt_common/interface.dart';
import 'package:pritt_common/version.dart';

import '../loader.dart';
import 'base.dart';
import 'base/config.dart';
import 'base/workspace.dart';

final goHandler = Handler<GoModConfig>(
  id: 'go',
  name: 'go',
  language: 'go',
  config: Loader('go.mod', load: (contents) => contents),
  packageManager: PackageManager(
    name: 'go',
    onAdd: () {
      return PackageCmdArgs(
        args: ['go', 'get'],
        resolveType: (String name, PackageType type) =>
            ([name], collate: false),
        resolveVersion: (String name, String? version) => '$name/v$version',
      );
    },
    onRemove: (name) => ['go', 'get', '$name@none'],
    onGet: () => ['go', 'get'],
  ),
  onGetConfig: (directory, controller) async {
    // tricky: to read a go.mod file
    final configJson = await controller.run(
      'go',
      args: ['mod', 'edit', '-json'],
      directory: directory,
    );

    // get the current user
    final currentAuthor = await controller.getCurrentAuthor();

    final goMod = GoModConfig.fromGoModJson(
      jsonDecode(configJson),
      currentAuthor,
    );

    return goMod;
  },
  onGetWorkspace: (directory, controller) async {
    return Workspace(
      config: await controller.getConfiguration(directory),
      directory: directory,
      name: directory,
    );
  },
  onConfigure: (context, controller) async => [],
);

class GoModConfig extends Config {
  final String goVersion;
  final String moduleName;

  const GoModConfig({
    required super.name,
    required super.version,
    required super.author,
    required this.goVersion,
    required this.moduleName,
  });

  factory GoModConfig.fromGoModJson(Map<String, dynamic> json, Author author) {
    final module = json['Module']['Path'] as String;
    final goVersion = json['Go'] as String;

    final moduleParts = module.split('/');
    final lastModulePart = moduleParts.last;

    final String version;
    final String name;

    switch (moduleParts.skip(1)) {
      case [String moduleScope, String moduleName, String moduleVersion]
          when moduleVersion.startsWith('v') &&
              Version.tryParse(moduleVersion.substring(1)) != null:
        name = '@$moduleScope/$moduleName';
        version = moduleVersion;
        break;
      case [String moduleName, String moduleVersion]
          when moduleVersion.startsWith('v') &&
              Version.tryParse(moduleVersion.substring(1)) != null:
        name = moduleName;
        version = moduleVersion;
        break;
      case [String moduleScope, String moduleName]:
        name = '@$moduleScope/$moduleName';
        version = '1.0.0';
        break;
      case [String moduleName]:
        name = moduleName;
        version = '1.0.0';
        break;
      default:
        if (lastModulePart.startsWith('v') &&
            Version.tryParse(lastModulePart.substring(1)) != null) {
          // last part is version
          version = lastModulePart.substring(1);
          name = moduleParts.sublist(1, moduleParts.length - 1).join('/');
        } else {
          version = '1.0.0';
          name = lastModulePart;
        }
        break;
    }

    return GoModConfig(
      name: name,
      version: version,
      author: author,
      goVersion: goVersion,
      moduleName: module,
    );
  }

  @override
  Map<String, dynamic> get configMetadata => {
    'go': goVersion,
    'module_name': moduleName,
  };

  @override
  Map<String, dynamic>? get rawConfig => null;
}

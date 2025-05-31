import 'dart:convert';

import 'package:pritt_cli/src/plugins/base.dart';
import 'package:pritt_cli/src/plugins/base/config.dart';
import 'package:pritt_cli/src/plugins/base/workspace.dart';
import 'package:pritt_common/interface.dart';
import 'package:yaml/yaml.dart';

final dartHandler = Handler<PubspecConfig>(
  id: 'dart',
  name: 'dart',
  language: 'dart',
  configFile: 'pubspec.yaml',
  packageManager: PackageManager(
      name: 'pub',
      args: ['dart', 'pub'],
      onGet: () => ['dart', 'pub', 'get'],
      onAdd: (info) {
        return PackageCmdArgs(
          args: ['dart', 'pub', 'add'],
          resolveType: (name, type) => [
            type == PackageType.dev ? 'dev:$name' : name,
          ],
          resolveVersion: (name, version) => '$name:^$version',
          resolveUrl: (name, url) => (
            [
              name,
              if (url != null) ...['--hosted-url', url]
            ],
            singleUse: true
          ),
        );
      },
      onRemove: (info) => ['dart', 'pub', 'remove']),
  onGetConfig: (directory, controller) async {
    // read the configuration file
    final config = await controller.readConfigFile(directory);

    // once gotten, read the config file
    final configData = jsonDecode(jsonEncode(loadYaml(config)));

    // get the current user
    final currentAuthor = await controller.getCurrentAuthor();

    // return configuration
    return PubspecConfig.fromJson(configData, currentAuthor);
  },
  onGetWorkspace: (directory, controller) async {
    return Workspace(
        config: await controller.getConfiguration(directory),
        directory: directory,
        name: directory);
  },
  onConfigure: (context, controller) {
    // use package manager hosted commands
    controller.useHostedPMCommands();
  },
);

class PubspecConfig extends Config {
  const PubspecConfig._(
      {required super.name,
      required super.version,
      required super.description,
      required super.author,
      super.private});

  factory PubspecConfig.fromJson(Map<String, dynamic> json, Author author) {
    return PubspecConfig._(
        name: json['name'] as String,
        version: json['version'] as String,
        description: json['description'] as String,
        author: author,
        private: json['publish_to'] == 'none');
  }
}

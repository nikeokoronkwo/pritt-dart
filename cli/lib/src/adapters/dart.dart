import 'dart:convert';

import 'package:pritt_common/interface.dart';
import 'package:yaml/yaml.dart';

import '../loader.dart';
import 'base.dart';
import 'base/config.dart';
import 'base/workspace.dart';

final dartHandler = Handler<PubspecConfig>(
  id: 'dart',
  name: 'dart',
  language: 'dart',
  config: Loader('pubspec.yaml', load: (contents) => contents),
  ignore: Loader('.pubignore',
      load: (contents) => const LineSplitter()
          .convert(contents)
          .skipWhile((c) => c.trim().startsWith('#'))
          .toList()
        ..addAll(['.dart_tool', 'pubspec.lock'])),
  usePMForHostedPkgs: true,
  packageManager: PackageManager(
      name: 'pub',
      args: ['dart', 'pub'],
      onGet: () => ['dart', 'pub', 'get'],
      onAdd: () {
        return PackageCmdArgs(
          args: ['dart', 'pub', 'add'],
          resolveType: (name, type) => (
            [
              type == PackageType.dev ? 'dev:$name' : name,
            ],
            collate: false
          ),
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

  onConfigure: (context, controller) async {
    final tokenUrls = const LineSplitter().convert(await controller.run('dart', args: ['pub', 'token', 'list']))
      .map((line) => line.trim())
      .where((line) => line.startsWith('http'));
    
    if (!tokenUrls.any((line) => line.contains(controller.instanceUri))) {
      // add token
      await controller.run('dart', args: ['pub', 'token', 'add', controller.instanceUri, '--env-var', 'PRITT_AUTH_TOKEN']);
    }

    return [];
  },
);

class PubspecConfig extends Config {
  const PubspecConfig._(
      {required super.name,
      required super.version,
      super.description,
      required super.author,
      super.private,
      required this.rawConfig});

  factory PubspecConfig.fromJson(Map<String, dynamic> json, Author author) {
    return PubspecConfig._(
        name: json['name'] as String,
        version: json['version'] as String,
        description: json['description'] as String?,
        author: author,
        private: json['publish_to'] == 'none',
        rawConfig: json);
  }

  @override
  Map<String, dynamic> get configMetadata => {};

  @override
  final Map<String, dynamic> rawConfig;
}

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_cli/src/adapters/base.dart';
import 'package:pritt_cli/src/adapters/base/config.dart';
import 'package:pritt_cli/src/adapters/base/workspace.dart';
import 'package:pritt_cli/src/loader.dart';
import 'package:pritt_common/interface.dart';
import 'package:pritt_common/version.dart';

final goHandler = Handler<GoModConfig>(
    id: 'go',
    name: 'go',
    language: 'go',
    config: Loader('go.mod', load: (contents) => contents),
    packageManager: PackageManager(
        name: 'go',
        onAdd: (info) {
          return PackageCmdArgs(
            args: ['go', 'get'],
            resolveType: (String name, PackageType type) => [name],
            resolveVersion: (String name, String? version) => '$name/v$version',
          );
        },
        onRemove: (info) => ['go', 'get', '${info.name}@none'],
        onGet: () => ['go', 'get']),
    onGetConfig: (directory, controller) async {
      // tricky: to read a go.mod file
      final configJson = await controller.run('go',
          args: ['mod', 'edit', '-json'], directory: directory);

      // get the current user
      final currentAuthor = await controller.getCurrentAuthor();

      final goMod =
          GoModConfig.fromGoModJson(jsonDecode(configJson), currentAuthor);

      return goMod;
    },
    onGetWorkspace: (directory, controller) async {
      return Workspace(
          config: await controller.getConfiguration(directory),
          directory: directory,
          name: directory);
    },
    onConfigure: (context, controller) async {});

@JsonSerializable(createFactory: false)
class GoModConfig extends Config {
  final String goVersion;

  GoModConfig(
      {required super.name,
      required super.version,
      required super.author,
      required this.goVersion});

  factory GoModConfig.fromGoModJson(Map<String, dynamic> json, Author author) {
    final module = json['Module']['Path'] as String;
    final goVersion = json['Go'] as String;

    final moduleParts = module.split('/');
    final lastModulePart = moduleParts.last;

    final String version;
    final String name;

    if (lastModulePart.startsWith('v') &&
        Version.tryParse(lastModulePart.substring(1)) != null) {
      // last part is version
      version = lastModulePart.substring(1);
      name = moduleParts.sublist(1, moduleParts.length - 1).join('/');
    } else {
      version = '1.0.0';
      name = lastModulePart;
    }

    return GoModConfig(
        name: name, version: version, author: author, goVersion: goVersion);
  }
}

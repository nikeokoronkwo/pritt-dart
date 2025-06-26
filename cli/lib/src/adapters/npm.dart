import 'dart:convert';

import 'package:io/ansi.dart';
import 'package:pritt_common/interface.dart';

import '../loader.dart';
import 'base.dart';
import 'base/config.dart';
import 'base/workspace.dart';
import 'npm/package_managers.dart';

final npmHandler = MultiPackageManagerHandler<PackageJsonConfig>(
    id: 'npm',
    name: 'npm',
    language: 'javascript',
    config: Loader('package.json', load: (contents) => contents),
    ignore: Loader(
      '.npmignore',
      load: (contents) => const LineSplitter()
          .convert(contents)
          .skipWhile((line) => line.trim().startsWith('#'))
          .toList()
        ..addAll(['.npmignore', '.npmrc', 'config.gypi', 'npm-debug.log']),
    ),
    packageManagers: {
      for (final pm in NpmPackageManager.values) pm.toString(): pm.pmObject
    },
    publisher: PublishManager.pm,
    onGetConfig: (directory, controller) async {
      final configFile = await controller.readConfigFile(directory);

      final config = jsonDecode(configFile);

      return PackageJsonConfig.fromJson(
          config, await controller.getCurrentAuthor());
    },
    onGetWorkspace: (directory, controller) async {
      // check the config files present
      NpmPackageManager pm;

      if (await controller.fileExists('pnpm-lock.yaml')) {
        pm = NpmPackageManager.pnpm;
      } else if (await controller.fileExists('yarn.lock')) {
        pm = NpmPackageManager.yarn;
      } else if (await controller.fileExists('bun.lock') ||
          await controller.fileExists('bun.lockb')) {
        pm = NpmPackageManager.bun;
      } else {
        pm = NpmPackageManager.npm;
      }

      // read config
      return Workspace(
          config: await controller.getConfiguration(directory),
          directory: directory,
          name: directory,
          packageManager: pm.pmObject);
    },
    onConfigure: (context, controller) async {
      final pm = context.workspace.packageManager;

      Map<String, String> npmRc = {};

      // create .npmrc if not exists
      if (await controller.fileExists('.npmrc')) {
        npmRc = const LineSplitter()
            .convert(await controller.readFileAt('.npmrc'))
            .asMap()
            .map((_, v) {
          final [key, value] = v.split('=');
          return MapEntry(key, value);
        });
      }

      npmRc['@pritt:registry'] = controller.instanceUri;

      await controller.writeFileAt(
          '.npmrc', npmRc.entries.map((e) => '${e.key}=${e.value}').join('\n'));

      controller.log(
          "${styleBold.wrap("NOTE:")} When using the local package manager, install 'pkg' as: ${styleUnderlined.wrap('${pm?.name ?? 'npm'} add @pritt/pkg')}");
      return null;
    });

class PackageJsonConfig extends Config {
  PackageJsonConfig._(
      {required super.name,
      required super.version,
      required super.description,
      required super.author,
      super.license,
      super.private,
      required this.rawConfig});

  factory PackageJsonConfig.fromJson(Map<String, dynamic> json, Author author) {
    return PackageJsonConfig._(
        name: json['name'],
        version: json['version'],
        description: json['description'],
        author: author,
        license: json['license'],
        private: json['private'],
        rawConfig: json);
  }

  @override
  // TODO: implement configMetadata
  Map<String, dynamic> get configMetadata => {};

  @override
  final Map<String, dynamic> rawConfig;
}

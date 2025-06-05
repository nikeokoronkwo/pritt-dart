import 'dart:convert';

import 'package:io/ansi.dart';
import 'package:pritt_cli/src/adapters/base.dart';
import 'package:pritt_cli/src/adapters/base/config.dart';
import 'package:pritt_cli/src/adapters/npm/package_managers.dart';
import 'package:pritt_cli/src/loader.dart';
import 'package:pritt_common/interface.dart';

// TODO: How to handle more than just 'npm'?
final npmHandler = MultiPackageManagerHandler<PackageJsonConfig>(
    id: 'npm',
    name: 'npm',
    language: 'javascript',
    config: Loader('package.json', load: (contents) => contents),
    ignore: Loader('.npmignore', load:(contents) => const LineSplitter().convert(contents).skipWhile((line) => line.trim().startsWith('#')).toList()
    ..addAll(['.npmignore', '.npmrc', 'config.gypi', 'npm-debug.log']),),
    packageManagers: {
      for (final pm in NpmPackageManager.values) pm.toString(): pm.pmObject
    },
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

      final packageManager = pm.pmObject;
      return null;

      // read config
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
    });

class PackageJsonConfig extends Config {
  PackageJsonConfig._(
      {required super.name,
      required super.version,
      required super.description,
      required super.author,
      super.license,
      super.private});

  factory PackageJsonConfig.fromJson(Map<String, dynamic> json, Author author) {
    return PackageJsonConfig._(
        name: json['name'],
        version: json['version'],
        description: json['description'],
        author: author,
        license: json['license'],
        private: json['private']);
  }
}

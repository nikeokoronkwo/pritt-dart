import 'dart:convert';

import '../loader.dart';
import 'base.dart';
import 'base/workspace.dart';
import 'swift/config.dart';

final swiftHandler = Handler(
  id: 'swift',
  name: 'swift',
  language: 'swift',
  config: Loader('Package.swift', load: (contents) => contents),
  packageManager: PackageManager(
    name: 'swift',
    onAdd: () {
      return PackageCmdArgs(
        args: [
          'swift',
          'package'
              'add-dependency',
        ],
        resolveType: (String name, PackageType type) =>
            ([name, '--type', ''], collate: false),
        resolveVersion: (String name, String? version) => '$name --to $version',
      );
    },
    onRemove: (name) => throw Exception('Unsupported Operation'),
    onGet: () => ['swift', 'package', 'resolve'],
  ),
  onGetConfig: (directory, controller) async {
    final configJson = await controller.run(
      'swift',
      args: ['package', 'dump-package'],
      directory: directory,
    );

    final currentAuthor = await controller.getCurrentAuthor();
    final v = controller.getPrittConfig()?.version;
    if (v == null) {
      throw Exception(
        'Could not get version of Swift package. Please specify a version in your pritt.yaml file.',
      );
    }

    return PackageSwiftConfig.fromJson(
      jsonDecode(configJson),
      author: currentAuthor,
      version: v,
    );
  },
  onGetWorkspace: (directory, controller) async {
    return Workspace(
      config: await controller.getConfiguration(directory),
      directory: directory,
      name: directory,
    );
  },
  onConfigure: (context, controller) async {
    // login to registry
    final _ = await controller.run(
      'swift',
      args: [
        'package-registry',
        'login',
        '--token',
        r'$PRITT_AUTH_TOKEN',
        controller.instanceUri,
      ],
    );

    // set the registry
    final _ = await controller.run(
      'swift',
      args: [
        'package-registry',
        'set',
        if (Uri.parse(controller.instanceUri).scheme == 'http')
          '--allow-insecure-http',
        controller.instanceUri,
      ],
    );

    // done!
    return [];
  },
);

import '../base/workspace.dart';

final npmPM = PackageManager(
    name: 'npm',
    onAdd: () {
      return PackageCmdArgs(
        args: ['npm', 'install'],
        resolveType: (name, type) {
          return (switch (type) {
            PackageType.normal => [name],
            PackageType.dev => ['--save-dev', name],
            PackageType.peer => ['--save-peer', name],
            PackageType.optional => ['--save-optional', name],
            _ => [name]
          }, collate: true);
        },
        resolveVersion: (name, version) => '$name@$version',
      );
    },
    onGet: () => ['npm', 'install'],
    onRemove: (name) => ['npm', 'uninstall', name],
    onPublish: (name) {
      assert(name.startsWith('@pritt'),
          "In order to publish to pritt, you should have the '@pritt' namespace ");
      return ['npm', 'publish'];
    });

final pnpmPM = PackageManager(
    name: 'pnpm',
    onAdd: () {
      return PackageCmdArgs(
        args: ['pnpm', 'add'],
        resolveType: (name, type) {
          return (switch (type) {
            PackageType.normal => [name],
            PackageType.dev => ['-D', name],
            PackageType.peer => ['--save-peer', name],
            PackageType.optional => ['-O', name],
            _ => [name]
          }, collate: true);
        },
        resolveVersion: (name, version) => '$name@$version',
      );
    },
    onGet: () => ['pnpm', 'install'],
    onRemove: (name) => ['pnpm', 'remove', name],
    onPublish: (name) {
      assert(name.startsWith('@pritt'),
          "In order to publish to pritt, you should have the '@pritt' namespace ");
      return ['pnpm', 'publish'];
    });

final bunPM = PackageManager(
    name: 'bun',
    onAdd: () {
      return PackageCmdArgs(
        args: ['bun', 'add'],
        resolveType: (name, type) {
          return (switch (type) {
            PackageType.normal => [name],
            PackageType.dev => ['-d', name],
            PackageType.peer => ['--peer', name],
            PackageType.optional => ['--optional', name],
            _ => [name]
          }, collate: true);
        },
        resolveVersion: (name, version) => '$name@$version',
      );
    },
    onGet: () => ['bun', 'install'],
    onRemove: (name) => ['bun', 'remove', name],
    onPublish: (name) {
      assert(name.startsWith('@pritt'),
          "In order to publish to pritt, you should have the '@pritt' namespace ");
      return ['bun', 'publish'];
    });

final yarnPM = PackageManager(
    name: 'yarn',
    onAdd: () {
      return PackageCmdArgs(
        args: ['yarn', 'add'],
        resolveType: (name, type) {
          return (switch (type) {
            PackageType.normal => [name],
            PackageType.dev => ['-D', name],
            PackageType.peer => ['-P', name],
            PackageType.optional => ['-O', name],
            _ => [name]
          }, collate: true);
        },
        resolveVersion: (name, version) => '$name@$version',
      );
    },
    onGet: () => ['yarn', 'install'],
    onRemove: (name) => ['yarn', 'remove', name],
    onPublish: (name) {
      assert(name.startsWith('@pritt'),
          "In order to publish to pritt, you should have the '@pritt' namespace ");
      return ['yarn', 'publish'];
    });

enum NpmPackageManager {
  npm,
  pnpm,
  yarn,
  bun;

  const NpmPackageManager();

  PackageManager get pmObject {
    return switch (this) {
      NpmPackageManager.npm => npmPM,
      NpmPackageManager.pnpm => pnpmPM,
      NpmPackageManager.yarn => yarnPM,
      NpmPackageManager.bun => throw UnimplementedError("TODO: Implement bun"),
    };
  }
}

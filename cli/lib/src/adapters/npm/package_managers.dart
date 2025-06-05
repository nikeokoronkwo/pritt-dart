import 'package:pritt_cli/src/adapters/base/workspace.dart';

final npmPM = PackageManager(
    name: 'npm',
    onAdd: (info) {
      return PackageCmdArgs(
        args: ['npm', 'install'],
        resolveType: (name, type) {
          return switch (type) {
            PackageType.normal => [name],
            PackageType.dev => ['--save-dev', name],
            PackageType.peer => ['--save-peer', name],
            PackageType.optional => ['--save-optional', name],
            _ => [name]
          };
        },
        resolveVersion: (name, version) => '$name@$version',
      );
    },
    onGet: () => ['npm', 'install'],
    onRemove: (info) => ['npm', 'uninstall', info.name]);

final pnpmPM = PackageManager(
    name: 'pnpm',
    onAdd: (info) {
      return PackageCmdArgs(
        args: ['pnpm', 'add'],
        resolveType: (name, type) {
          return switch (type) {
            PackageType.normal => [name],
            PackageType.dev => ['-D', name],
            PackageType.peer => ['--save-peer', name],
            PackageType.optional => ['-O', name],
            _ => [name]
          };
        },
        resolveVersion: (name, version) => '$name@$version',
      );
    },
    onGet: () => ['pnpm', 'install'],
    onRemove: (info) => ['pnpm', 'remove', info.name]);

final yarnPM = PackageManager(
    name: 'yarn',
    onAdd: (info) {
      return PackageCmdArgs(
        args: ['yarn', 'add'],
        resolveType: (name, type) {
          return switch (type) {
            PackageType.normal => [name],
            PackageType.dev => ['-D', name],
            PackageType.peer => ['-P', name],
            PackageType.optional => ['-O', name],
            _ => [name]
          };
        },
        resolveVersion: (name, version) => '$name@$version',
      );
    },
    onGet: () => ['yarn', 'install'],
    onRemove: (info) => ['yarn', 'remove', info.name]);

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

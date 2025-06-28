import 'config.dart';

class Workspace<T extends Config> {
  final T config;
  final String directory;
  final String name;
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

class PackageWorkspace extends Workspace {
  PackageWorkspace(
      {required super.config, required super.directory, required super.name});
}

/// NOTE: This is a stub for a future feature, not used at the moment
class MonorepoWorkspace extends Workspace {
  MonorepoWorkspace(
      {required super.config, required super.directory, required super.name});
}

// TODO(nikeokoronkwo): Add better support for adding, removing packages, https://github.com/nikeokoronkwo/pritt-dart/issues/53
class PackageManager {
  String name;
  List<String> args;

  // TODO(nikeokoronkwo): For now, packages are added one-by-one unless packages are only passed with name and version
  //  Fix this to add multiple packages at once, https://github.com/nikeokoronkwo/pritt-dart/issues/53
  PackageCmdArgs Function() onAdd;
  List<String> Function(String name) onRemove;
  List<String> Function(String name)? onPublish;
  List<String> Function() onGet;

  PackageManager(
      {required this.name,
      List<String>? args,
      required this.onAdd,
      required this.onRemove,
      this.onPublish,
      required this.onGet})
      : args = args ?? [name];
}

/// Process:
/// pkgName -> resolveVersion -> resolveType -> resolveUrl
class PackageCmdArgs {
  /// major args to run the command
  final List<String> args;

  /// used to resolve args when given a package name and type
  final (List<String>, {bool? collate}) Function(String name, PackageType type)
      resolveType;

  /// used to resolve args when given a package name and version
  final String Function(String name, String? version) resolveVersion;

  /// used to resolve args when given a package name and url
  final (List<String>, {bool singleUse}) Function(String name, String? url)?
      resolveUrl;

  PackageCmdArgs({
    required this.args,
    required this.resolveType,
    required this.resolveVersion,
    this.resolveUrl,
  });
}

class PackageInformation {
  String name;
  String? version;
  PackageType type;
  String? url;

  PackageInformation({
    required this.name,
    this.version,
    required this.type,
    this.url,
  });
}

enum PackageType { normal, dev, peer, optional, other }

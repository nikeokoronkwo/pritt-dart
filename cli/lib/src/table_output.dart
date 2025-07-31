import 'dart:io';

import '../../../packages/common/lib/interface.dart';

import 'cli/table.dart';
import 'parse_name.dart';
import 'workspace/workspace.dart';

enum TerminalSize {
  small,
  medium,
  large;

  static TerminalSize fromSize(int col) {
    if (col > 120) {
      return large;
    } else if (col >= 100) {
      return medium;
    } else {
      return small;
    }
  }
}

String listPackageInfo(List<Package> pkgs) {
  int terminalColumns;
  try {
    terminalColumns = stdout.terminalColumns;
  } on StdoutException catch (_) {
    // in the case of testing, improper terminal kind
    terminalColumns = 100;
  }
  final terminalSize = TerminalSize.fromSize(terminalColumns);
  final headers = ['Name', 'Author', 'Latest Version', 'Language'];

  final pkgList = pkgs.map((package) {
    final authorName = parseName(package.author.name);
    return [
      package.name,
      switch (terminalSize) {
        TerminalSize.small =>
          '${authorName.$1} ${authorName.$2?[0].toUpperCase()}.',
        TerminalSize.medium => package.author.name,
        TerminalSize.large =>
          '${package.author.name} <${package.author.email}>',
      },
      package.version,
      package.language ?? 'unknown',
    ];
  }).toList();

  return Table(pkgList, header: headers).write();
}

String listAdapterInfo(List<Plugin> plugins) {
  final headers = ['Name', 'Version', 'Language'];

  final pkgList = plugins.map((plugin) {
    return [plugin.name, plugin.version, plugin.language ?? 'unknown'];
  }).toList();

  return Table(pkgList, header: headers).write();
}

Future<String> listProjectInfo(Project project) async {
  final headers = ['Item', 'Info', 'Comment'];

  final config = await project.getWorkspace();

  final items = [
    ['Name', config.name, ''],
    [
      'Language',
      project.primaryHandler.language,
      'Deduced from handler #${project.primaryHandler.id}',
    ],
    [
      'Package Manager',
      config.packageManager?.name ?? 'none',
      if (config.packageManager?.name == null)
        'No package manager associated with #${project.primaryHandler.id}'
      else
        '',
    ],
    ['VCS', project.vcs.name, ''],
  ];

  return Table(items, header: headers).write();
}

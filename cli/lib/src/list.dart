
import 'dart:io';

import 'package:pritt_cli/src/cli/table.dart';
import 'package:pritt_common/interface.dart';

enum TerminalSize {
  small, medium, large;

  static TerminalSize fromSize(int col) {
    if (col > 120) return large;
    else if (col >= 100) return medium;
    else return small;
  }
}

String listPackageInfo(List<Package> pkgs) {
  var terminalColumns;
  try {
    terminalColumns = stdout.terminalColumns;
  } on StdoutException catch (_) {
    // in the case of testing, improper terminal kind
    terminalColumns = 100;
  }
  final terminalSize = TerminalSize.fromSize(terminalColumns);
  final headers = ['Name', 'Author'];

  final pkgList = pkgs.map((package) {
    final authorName = parseName(package.author.name);
    return [package.name, switch (terminalSize) {

    TerminalSize.small => '${authorName.$1} ${authorName.$2?[0].toUpperCase()}.',
    TerminalSize.medium => package.author.name,
    TerminalSize.large => '${package.author.name} <${package.author.email}>',
  }, ];
  }).toList();

  return Table(pkgList, header: headers).write();
}

(String, String?) parseName(String name) {
  final [first, ...last] = name.split(' ');
  if (last.isEmpty) return (first, null);
  return (first, last.join(' '));
}
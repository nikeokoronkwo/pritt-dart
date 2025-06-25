import 'dart:convert';

import 'package:io/io.dart';
import 'package:path/path.dart' as p;
import 'package:pritt_common/interface.dart';

import 'utils/log.dart';

Future<String?> _runCommand(String executable, List<String> args, {ProcessManager? manager, String? directory, Logger? logger}) async {
  logger ??= Logger();
  manager ??= ProcessManager();
  final process = await manager
      .spawn(executable, args, workingDirectory: directory ?? p.current);

  final stdout = await process.stdout.transform(utf8.decoder).join();
  final stderr = await process.stderr.transform(utf8.decoder).join();
  final exitCode = await process.exitCode;

  if (exitCode == 0) {
    return stdout.trim();
  } else {
    logger.verbose('STDOUT: $stdout');
    logger.verbose('STDERR: $stderr');
    return null;
  }
}

Future<String?> getVcsRemoteUrl(VCS vcs, {String? directory}) async {
    return switch (vcs) {
      VCS.git =>
        await _runCommand('git', ['config', '--get', 'remote.origin.url'], directory: directory),
      VCS.svn => await _runCommand('svn', ['info', '--show-item', 'url'], directory: directory),
      VCS.fossil => await _runCommand('fossil', ['remote-url'], directory: directory) ??
          await _runCommand('fossil', ['info'], directory: directory).then((out) {
            final match = RegExp(r'url:\s*(.*)').firstMatch(out ?? '');
            return match?.group(1);
          }),
      VCS.mercurial => await _runCommand('hg', ['paths', 'default'], directory: directory),
      _ => null
    };
  }

Future<List<String>> getIgnoredVCSFiles(VCS vcs, {String? directory}) async {
  final splitter = const LineSplitter();
  switch (vcs) {
    case VCS.git:
      return splitter.convert(await _runCommand('git', ['ls-files', '--others', '-i', '--exclude-standard'], directory: directory) ?? '');
    case VCS.mercurial:
      return splitter.convert(await _runCommand('hg', ['status', '-i']) ?? '');
    case VCS.fossil:
      return splitter.convert(await _runCommand('fossil', ['extras'], directory: directory) ?? '');
    case VCS.svn:
      final result = await _runCommand('svn', ['status', '--no-ignore']);
      return splitter.convert(result ?? '')
          .where((line) =>
              line.isNotEmpty && line.startsWith('I')) // ignore ignored files
          .map((line) => line.substring(8).trim()) // extract file path
          .toList();
    default:
      return [];
  }
}
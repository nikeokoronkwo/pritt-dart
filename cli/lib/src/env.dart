import 'dart:io';

import 'utils/extensions.dart';
import 'utils/log.dart';

Future<int> _addEnvVarLinux(String key, String value, {Logger? logger}) async {
  logger ??= Logger();
  final shellFile = File('${Platform.environment['HOME']}/.bashrc');
  final exportLine = 'export $key="$value"';

  // Avoid duplicate entries
  if (await shellFile.readAsString().then((s) => s.contains(exportLine), onError: (_) => false)) {
    print('$key already set.');
    return 0;
  }

  await shellFile.writeAsString('\n$exportLine\n', mode: FileMode.append);

  final processResult = await Process.run('bash', ['-c', 'source ~/.bashrc']);

  logger.stdout('Pritt Auth Token saved to "~/.bashrc"');

  return processResult.exitCode;
}

Future<int> _addEnvVarMacOS(String key, String value, {Logger? logger}) async {
  logger ??= Logger();
  var shellFile = File('${Platform.environment['HOME']}/.zshrc');
  bool isBash = false;
  if (!shellFile.existsSync()) {
    isBash = true;
    shellFile = File('${Platform.environment['HOME']}/.bashrc');
  }

  final exportLine = 'export $key="$value"';

  // Avoid duplicate entries
  if (await shellFile.readAsString().then((s) => s.contains(exportLine), onError: (_) => false)) {
    logger.warn('$key already set.');
    return 0;
  }

  await shellFile.writeAsString('\n$exportLine\n', mode: FileMode.append);

  final processResult = isBash ? await Process.run('bash', ['-c', 'source ~/.bashrc'])
  : await Process.run('zsh', ['-c', 'source ~/.zshrc']);

  logger.stdout('Pritt Auth Token saved to "${isBash ? '~/.bashrc' : '~/.zshrc'}"');

  return processResult.exitCode;
}


Future<int> _addEnvVarWindows(String key, String value, {Logger? logger}) async {
  final result = await Process.run('setx', [key, value]);
  return result.exitCode;
}

Future<int> addEnvVar(String key, String value, {Logger? logger}) async {
  return switch (platform) {
    PlatformType.macos => _addEnvVarMacOS(key, value, logger: logger),
    PlatformType.linux => _addEnvVarLinux(key, value, logger: logger),
    PlatformType.windows => _addEnvVarWindows(key, value, logger: logger),
    _ => throw Exception('Unsupported Platform ${platform.name}')
  };
}


import 'dart:io';

import 'package:io/io.dart';

import 'utils/extensions.dart';

Future<Process> launchUrl(Uri uri, {ProcessManager? manager}) async {
  manager ??= ProcessManager();

  final v = await switch (platform) {
    PlatformType.macos => manager.spawnDetached('open', [uri.toString()]),
    PlatformType.windows => manager.spawnDetached('start', [uri.toString()]),
    PlatformType.linux => manager.spawnDetached('xdg-open', [uri.toString()]),
    _ => throw Exception('Unsupported Platform for running URL')
  };

  return v;
}

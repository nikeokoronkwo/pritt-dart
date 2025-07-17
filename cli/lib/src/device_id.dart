import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

Future<String> getDeviceId() async {
  String rawIdentifier;
  try {
    if (Platform.isLinux || Platform.isAndroid) {
      final file = File('/etc/machine-id');
      if (await file.exists()) {
        rawIdentifier = await file.readAsString();
      } else {
        rawIdentifier = Platform.localHostname;
      }
    } else if (Platform.isMacOS) {
      // Use IOPlatformUUID from macOS
      final result = await Process.run('ioreg', [
        '-rd1',
        '-c',
        'IOPlatformExpertDevice',
      ]);
      final match = RegExp(
        r'"IOPlatformUUID" = "([^"]+)"',
      ).firstMatch(result.stdout.toString());
      rawIdentifier = match?.group(1) ?? Platform.localHostname;
    } else if (Platform.isWindows) {
      // Use Windows UUID
      final result = await Process.run('wmic', ['csproduct', 'get', 'uuid']);
      final lines = result.stdout.toString().split('\n');
      rawIdentifier = lines.length >= 2
          ? lines[1].trim()
          : Platform.localHostname;
    } else {
      // Fallback for unknown platforms
      rawIdentifier = Platform.localHostname;
    }
  } catch (e) {
    rawIdentifier = Platform.localHostname;
  }

  final bytes = utf8.encode('pt_cli_$rawIdentifier');
  final hash = sha256.convert(bytes).toString();

  return 'ptc_${hash.substring(0, 20)}';
}

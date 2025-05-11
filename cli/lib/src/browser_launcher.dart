
import 'dart:io';

import 'utils/extensions.dart';

void launchUrl(Uri uri) {
  switch (platform) {
    case PlatformType.macos:
      Process.runSync('open', [uri.toString()]);
      break;
    case PlatformType.windows:
      Process.runSync('start', [uri.toString()]);
      break;
    case PlatformType.linux:
      try {

      } catch (e) {

      }
    default:
  }
}
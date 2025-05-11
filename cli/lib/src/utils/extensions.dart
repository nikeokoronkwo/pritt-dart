import 'dart:io';

extension IsSingle<T> on Iterable<T> {
  bool get isSingle => singleOrNull != null;
}

extension IsUrl on String {
  /// Checks if a given string is a url string
  bool get isUrl => Uri.tryParse(this) != null;
}

enum PlatformType {
  macos, ios, android, fuchsia, windows, linux
}


PlatformType get platform {
  if (Platform.isAndroid) return PlatformType.android;
  if (Platform.isFuchsia) return PlatformType.fuchsia;
  if (Platform.isIOS) return PlatformType.ios;
  if (Platform.isLinux) return PlatformType.linux;
  if (Platform.isMacOS) return PlatformType.macos;
  if (Platform.isWindows) return PlatformType.windows;
  throw Error();
}

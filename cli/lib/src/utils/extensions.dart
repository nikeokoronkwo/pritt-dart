import 'dart:io';

// actual extensions
extension IsSingle<T> on Iterable<T> {
  bool get isSingle => singleOrNull != null;
}

extension IsUrl on String {
  /// Checks if a given string is a url string
  bool get isUrl => Uri.tryParse(this) != null;
}

extension Limits<T extends num> on Iterable<T> {
  T get max {
    return fold(0 as T, (previous, current) {
      if (previous > current) {
        return previous;
      } else {
        return current;
      }
    });
  }

  T get min {
    return fold(0 as T, (previous, current) {
      if (previous < current) {
        return previous;
      } else {
        return current;
      }
    });
  }
}

// platform stuff
enum PlatformType { macos, ios, android, fuchsia, windows, linux }

PlatformType get platform {
  if (Platform.isAndroid) return PlatformType.android;
  if (Platform.isFuchsia) return PlatformType.fuchsia;
  if (Platform.isIOS) return PlatformType.ios;
  if (Platform.isLinux) return PlatformType.linux;
  if (Platform.isMacOS) return PlatformType.macos;
  if (Platform.isWindows) return PlatformType.windows;
  throw Error();
}

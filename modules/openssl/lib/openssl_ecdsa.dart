
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:file/local.dart';
import 'package:glob/glob.dart';

export 'src/native/openssl.dart'
  show OpenSSL;

/// Run the given function to load/look for OpenSSL and load if available on the user's system
/// 
/// You can use this if `--enable-experiment=native-assets` is not passed (by checking Platform.executableArguments)
ffi.DynamicLibrary loadOpenSSL([({String libSSL, String libCrypto})? libPaths]) {
  final libSSLPaths = Platform.isWindows ? [
    r'C:\Program Files\OpenSSL*\lib\libssl.dll',
    r'C:\Program Files (x86)\OpenSSL*\lib\libssl.dll',
    r'C:\**\vcpkg\installed\x64-windows\lib\libssl.dll',
  ] : [
    '/usr/lib/libssl.*',
    '/usr/local/lib/libssl.*',
    if (Platform.isMacOS) ...[
      '/opt/local/lib/**/libssl.dylib',
      '/opt/homebrew/lib/**/libssl.dylib'
    ]
  ];

  final libCryptoPaths = Platform.isWindows ? [
    r'C:\Program Files\OpenSSL*\lib\libcrypto.dll',
    r'C:\Program Files (x86)\OpenSSL*\lib\libcrypto.dll',
    r'C:\**\vcpkg\installed\x64-windows\lib\libcrypto.dll',
  ] : [
    '/usr/lib/libcrypto.*',
    '/usr/local/lib/libcrypto.*',
    if (Platform.isMacOS) ...[
      '/opt/local/lib/**/libcrypto.dylib',
      '/opt/homebrew/lib/**/libcrypto.dylib'
    ]
  ];

  _loadLib(libPaths?.libCrypto, libCryptoPaths);
  return _loadLib(libPaths?.libSSL, libSSLPaths);
}

ffi.DynamicLibrary _loadLib(String? libPath, List<String> libPaths) {
  String? path;
  if (libPath != null) {
    path = libPath;
  } else {
    for (final p in libPaths) {
      final glob = Glob(p, recursive: true);
      final files = glob.listFileSystemSync(const LocalFileSystem());
      if (files.isEmpty) {
        continue;
      } else {
        path = files.first.absolute.path;
        break;
      }
    }
  }
  
  if (path == null) throw Exception('Could not find lib path for OpenSSL. Pass the path manually or check that you have it installed');
  
  return ffi.DynamicLibrary.open(path);
}

class ECDSAKey {
  static final _finalizer = Finalizer((ptr) {

  });

  ECDSAKey() {
    // _finalizer.attach(value, finalizationToken)
  }
}

class ECDSAPrivateKey extends ECDSAKey {

}

class ECDSAPublicKey extends ECDSAKey {
  
}
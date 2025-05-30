@JS('fs')
library fs;

import 'dart:js_interop';

import 'iterator.dart';

@JS('cp')
external JSPromise cp(String src, String dest, [FSCPOptions? options]);

extension type FSCPOptions._(JSObject _) implements JSObject {
  external FSCPOptions({bool recursive, bool force});
  external bool get recursive;
  external bool get force;
}

@JS('readdir')
external JSPromise<JSArray<Dirent>> readdir(String path,
    [FSReadDirOptions? options]);

extension type FSReadDirOptions._(JSObject _) implements JSObject {
  external FSReadDirOptions(
      {String encoding, bool withFileTypes, bool recursive});
  external String? get encoding;
  external bool? get withFileTypes;
  external bool? get recursive;
}

extension type Dirent._(JSObject _) implements JSObject {
  external bool isFile();
  external bool isDirectory();
  external bool isSymbolicLink();
  external String name;
  external String parentPath;
}

@JS('copyFile')
external JSPromise copyFile(String src, String dest, [int? mode]);

@JS('mkdir')
external JSPromise mkdir(String path, [FSMkdirOptions? options]);

extension type FSMkdirOptions._(JSObject _) implements JSObject {
  external FSMkdirOptions({String mode, bool recursive});
  external String get mode;
  external bool get recursive;
}

@JS('writeFile')
external JSPromise writeFile(String output, JSAny code, [String? encoding]);

JSPromise writeFileAsString(String output, String code) =>
    writeFile(output, code.toJS, 'utf-8');

@JS('watch')
external JSAsyncIterator<FSWatchEvent> watch(String dir,
    [FSWatchOptions? options]);

/// TODO: .signal
extension type FSWatchOptions._(JSObject _) implements JSObject {
  external FSWatchOptions({bool persistent, bool recursive, String encoding});
  external bool get persistent;
  external bool get recursive;
  external String get encoding;
}

extension type FSWatchEvent._(JSObject _) implements JSObject {
  external FSWatchEvent({String? filename, String eventType});
  external String? get filename;
  external String get eventType;
}

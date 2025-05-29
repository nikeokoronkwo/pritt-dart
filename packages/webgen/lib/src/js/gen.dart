import 'dart:js_interop';

// Options
extension type AuthOptions._(JSObject _) implements JSObject {
  external AuthOptions({
    String name, String title,
    bool magicLink, bool passkey
  });
  external String get name;
  external String get title;
  external bool get magicLink;
  external bool get passkey;
}

// return types
extension type CodeReturnType._(JSObject _) implements JSObject {
  external CodeReturnType({String filename, String code});
  external String get filename;
  external String get code;
}

@JS()
external JSArray<CodeReturnType> generateAuthConfig(AuthOptions options);
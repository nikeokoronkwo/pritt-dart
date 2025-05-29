import 'dart:js_interop';

// Options
extension type AuthOptions._(JSObject _) implements JSObject {
  external AuthOptions({});
  
}

// return types
extension type CodeReturnType._(JSObject _) implements JSObject {
  external CodeReturnType({String filename, String code});
  external String get filename;
  external String get code;
}

@JS()
external JSArray<CodeReturnType> generateAuthConfig(AuthOptions options);
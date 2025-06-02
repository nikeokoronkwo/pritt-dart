import 'dart:js_interop';

import 'gen.dart';

extension type TemplateOptions._(JSObject _) implements JSObject {
  external TemplateOptions({AuthOptions auth, String name});
  // auth options
  external AuthOptions get auth;
  // the name
  external String get name;
}

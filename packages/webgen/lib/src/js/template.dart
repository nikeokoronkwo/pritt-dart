import 'dart:js_interop';

import 'package:node_interop/js.dart';

import 'gen.dart';

extension type TemplateOptions._(JSObject _) implements JSObject {
  external TemplateOptions({AuthOptions auth, String name, TimeOptions time});
  /// auth options
  external AuthOptions get auth;
  /// the name
  external String get name;
  /// the time options as an object
  external TimeOptions get time;
}

extension type TimeOptions._(JSObject _) implements JSObject {
  external TimeOptions({int year, int month, int day});
  factory TimeOptions.fromDateTime(DateTime time) {
    return TimeOptions(year: time.year, month: time.month, day: time.day);
  }

  external int get year;
  external int get month;
  external int get day;
}

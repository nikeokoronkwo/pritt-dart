import 'dart:js_interop';


import 'gen.dart';
import 'js.dart';

extension type TemplateOptions._(JSObject _) implements JSObject {
  external TemplateOptions(
      {AuthOptions auth, String name, TimeOptions time, StyleOptions style});

  /// auth options
  external AuthOptions get auth;

  /// the name
  external String get name;

  /// the time options as an object
  external TimeOptions get time;

  /// Styling Options
  external StyleOptions get style;
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

extension type StyleOptions._(JSObject _) implements JSObject {
  external StyleOptions({
    JSRecord<JSNumber, JSString> primary,
    JSRecord<JSNumber, JSString> secondary,
  });

  external StyleFontOptions get font;
}

extension type StyleFontOptions._(JSObject _) implements JSObject {
  external StyleFontOptions({String name, String type});
  external String get name;
  external String get type;
}

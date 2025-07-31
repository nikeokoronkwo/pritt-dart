import 'dart:js_interop';

import '../config/style.dart';
import 'js.dart';

@JS('generateTailwindColorScale')
external JSRecord<JSNumber, JSString> _generateTailwindColorScale(String scale);

WGTColourSpectrum generateTailwindColorScale(String scale) {
  final record = _generateTailwindColorScale(scale);
  return Map.fromIterables(
    keysFromRecord(record).toDart.map((v) => v.toDartInt),
    valuesFromRecord(record).toDart.map((v) => v.toDart),
  );
}

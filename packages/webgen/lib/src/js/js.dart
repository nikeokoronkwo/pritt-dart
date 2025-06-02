import 'dart:js_interop';

extension type JSRecord<K extends JSAny, V extends JSAny>._(JSObject _)
    implements JSObject {
  external JSRecord();
  external V operator [](K key);
  external void operator []=(K key, V value);
}

extension ToDartMap<K extends JSAny, V extends JSAny> on JSRecord<K, V> {
  Map<K, V> get toDart {
    return entriesFromRecord(this)
        .toDart
        .asMap()
        .map((k, v) => MapEntry(v.$0, v.$1));
  }
}

extension type JSTuple2<K extends JSAny, V extends JSAny>._(JSArray _)
    implements JSArray {
  K get $0 => this[0] as K;
  V get $1 => this[0] as V;
}

extension type JSArrayFunc<T extends JSAny, U extends JSAny>._(JSFunction _)
    implements JSFunction {
  external U call(T element, [JSNumber? index, JSArray<T>? array]);
}

extension JSArrayHelpers<T extends JSAny> on JSArray<T> {
  external JSArray<T> filter(JSArrayFunc<T, JSBoolean> where);
  external JSArray<U> map<U extends JSAny>(JSArrayFunc<T, U> map);
}

@JS('Object.entries')
external JSArray<JSTuple2<K, V>>
    entriesFromRecord<K extends JSAny, V extends JSAny>(JSRecord<K, V> record);

@JS('Object.keys')
external JSArray<K> keysFromRecord<K extends JSAny, V extends JSAny>(
    JSRecord<K, V> record);

@JS('Object.values')
external JSArray<V>
    valuesFromRecord<K extends JSAny, V extends JSAny>(JSRecord<K, V> record);

import 'dart:js_interop';

import 'js_helpers.dart';

extension type JSLibrary._(JSObject _) implements JSObject {
  @JS('parseOpenAPIDocumentSource')
  external JSPromise<OpenAPIGenResult> _parseOpenAPIDocumentSource(
    JSString source,
  );

  Future<OpenAPIGenResult> parseOpenAPIDocumentSource(String source) {
    return _parseOpenAPIDocumentSource(source.toJS).toDart;
  }
}

Future<JSLibrary> loadJSLib(String filename) async {
  return (await importModule(filename.toJS).toDart) as JSLibrary;
}

typedef Schema = JSObject;

extension type OpenAPIGenResult._(JSObject _) implements JSObject {
  external String? docs;
  external JSRecord<JSString, Schema> schemas;
  external JSArray<OAPIGenMethods> methods;
}

extension type OAPIGenMethods._(JSObject _) implements JSObject {
  external String? name;
  external String path;
  external String method;
  external String? summary;
  external String? description;
  external JSArray<OAPIGenMethodParameters> parameters;
  external OAPIGenSchema? body;
  external JSRecord<JSString, OAPIGenSchema>? returns;
}

extension type OAPIGenSchema._(JSObject _) implements JSObject {
  external String type;
  external String? name;
  external Schema schema;
  external bool? required;
}

extension type OAPIGenMethodsBody._(JSObject _) implements JSObject {
  external String? type;
  external String? name;
  external Schema? schema;
  external String? ref;
}

extension type OAPIGenMethodParameters._(JSObject _) implements JSObject {
  external String name;
  @JS('in')
  external String $in;
  external String? description;
  external bool? required;
  external bool? deprecated;
  external bool? allowEmptyValue;
  external Schema schema;
}

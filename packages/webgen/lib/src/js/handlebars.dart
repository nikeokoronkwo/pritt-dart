@JS('Handlebars')
library;

import 'dart:js_interop';

import 'js.dart';

@JS('compile')
external HandlebarsTemplateDelegate<T> compile<T extends JSObject>(
  JSAny input, [
  CompileOptions options,
]);

@JS('compile')
external HandlebarsTemplateDelegate compileString(
  String input, [
  CompileOptions options,
]);

typedef HandlebarsTemplateDelegate<T extends JSObject> = TemplateDelegate<T>;

extension type CompileOptions._(JSObject _) implements JSObject {
  external bool? data;
  external bool? compat;
  external JSRecord<JSString, JSBoolean>? knownHelpers;
  external bool? knownHelpersOnly;
  external bool? noEscape;
  external bool? strict;
  external bool? assumeObjects;
  external bool? preventIndent;
  external bool? ignoreStandalone;
  external bool? explicitPartialContext;
}

extension type TemplateDelegate<T extends JSObject>._(JSFunction _)
    implements JSFunction {
  String call(T context, [RuntimeOptions? options]) =>
      (options == null
                  ? callAsFunction(this, context)
                  : callAsFunction(this, context, options))
              .dartify()
          as String;
}

extension type RuntimeOptions._(JSObject _) implements JSObject {
  external bool? partial;
  external JSArray<JSAny>? depths;
  external JSRecord<JSString, JSFunction>? helpers;
  external JSRecord<JSString, HandlebarsTemplateDelegate>? partials;
  external JSRecord<JSString, JSFunction>? decorators;
  external JSAny data;
  external JSArray<JSAny>? blockParams;
  external bool? allowCallsToHelperMissing;
  external JSRecord<JSString, JSBoolean>? allowedProtoProperties;
  external JSRecord<JSString, JSBoolean>? allowedProtoMethods;
  external bool? allowProtoPropertiesByDefault;
  external bool? allowProtoMethodsByDefault;
}

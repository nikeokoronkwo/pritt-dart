import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:code_builder/code_builder.dart';

import '../js.dart';
import '../js_helpers.dart';

Iterable<Method> generateMethods(
    JSRecord<JSString, Schema> schemas, JSArray<OAPIGenMethods> methods,
    {Map<String, Spec> specs = const {}}) {
  return methods.toDart.map((method) {
    return Method((m) => m
      ..docs.addAll([
        if (method.summary != null) '**${method.summary}**',
        '${method.method} ${method.path}',
        '      ',
        if (method.description != null) method.description!,
        if (entriesFromRecord(method.returns!)
            .toDart
            .where((v) => v.$0.toDart != '200')
            .isNotEmpty)
          'Throws:\n${entriesFromRecord(method.returns!).filter(((JSTuple2<JSString, OAPIGenSchema> v) => v.$0.notEquals('200'.toJS)).toJS as JSArrayFunc<JSTuple2<JSString, OAPIGenSchema>, JSBoolean>).toDart.map((v) => '  - [${(v[1] as OAPIGenSchema).name}] on status code ${v[0]}').join('\n')}'
      ].map((d) {
        return const LineSplitter().convert(d).map((d) => '/// $d').join('\n');
      }))
      // name
      ..name = method.name ?? _toCamelCase(method.path.split('/'))
      // return type
      ..returns = TypeReference((t) => t
        ..symbol = 'FutureOr'
        ..url = 'dart:async'
        ..types.add(method.returns == null
            ? refer('void')
            : refer(method.returns!['200'.toJS].name ??
                switch (method.returns!['200'.toJS].type) {
                  'application/octet-stream' => 'StreamedContent',
                  'application/x-tar' => 'StreamedContent',
                  'application/gzip' => 'StreamedContent',
                  _ => 'dynamic'
                })))
      // body parameter
      ..requiredParameters.addAll([
        if (method.body != null)
          Parameter((p) => p
            ..name = 'body'
            ..type = method.body!.name == null
                ? (switch (method.body!.type) {
                    'application/octet-stream' => refer('StreamedContent'),
                    'application/x-tar' => refer('StreamedContent'),
                    'application/gzip' => refer('StreamedContent'),
                    _ => refer('dynamic')
                  })
                : TypeReference((t) => t
                  ..symbol = method.body!.name
                ))
      ])
      // other parameters
      ..optionalParameters.addAll(method.parameters.toDart.map((param) {
        var type = 'string';

        if (param.schema.getProperty('type'.toJS).dartify() as String ==
            'string')
          type = 'string';
        else if (param.schema.getProperty('type'.toJS).dartify() as String ==
            'number')
          type = 'number';
        else if (param.schema.getProperty('type'.toJS).dartify() as String ==
            'boolean')
          type = 'boolean';
        else if (param.schema.getProperty('type'.toJS).dartify() as String ==
            'integer')
          type = 'integer';
        else
          type = 'dynamic';

        return Parameter((p) => p
          ..name = param.name
          ..required = param.$in == 'path'
          ..named = true
          ..type = switch (type) {
            'string' => refer('String'),
            'integer' => refer('int'),
            'number' => refer('num'),
            'boolean' => refer('bool'),
            _ => refer('dynamic')
          });
      })));
  });
}

String _toCamelCase(List<String> words) {
  if (words.isEmpty) return '';

  final first = words.first.toLowerCase();
  final rest = words.skip(1).map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join();

  return first + rest;
}

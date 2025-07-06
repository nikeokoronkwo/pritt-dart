import 'dart:js_interop';
import 'package:code_builder/code_builder.dart';
import '../js.dart';
import '../js_helpers.dart';

Iterable<Class> generateBaseClasses(JSRecord<JSString, Schema> schemas,
    {List<String> contentTypes = const []}) {
  List<Class> classes = [
    // base content
    Class((c) => c
      ..name = "Content"
      ..constructors.add(Constructor((c) => c
        ..constant = true
        ..requiredParameters.add(Parameter((p) => p
          ..name = 'raw'
          ..toThis = true))))
      ..fields.add(Field((f) => f
        ..name = 'raw'
        ..type = refer('List<int>')
        ..modifier = FieldModifier.final$))
      ..methods.add(Method((m) => m
        ..name = 'length'
        ..returns = refer('int')
        ..type = MethodType.getter
        ..lambda = true
        ..body = const Code('raw.length')))),

    // text content
    Class((c) => c
          ..name = "TextContent"
          ..extend = refer('Content')
          ..constructors.add(Constructor((c) => c
            ..requiredParameters.add(Parameter((p) => p
              ..name = 'data'
              ..toThis = true))
            ..initializers.add(literal(refer('super'))
                .call([refer('data').property('codeUnits')]).code)))
          ..fields.add(Field((f) => f
            ..name = 'data'
            ..type = refer('String')
            ..modifier = FieldModifier.final$))
        // override
        ),

    // binary content
    Class((c) => c
      ..name = "BinaryContent"
      ..extend = refer('Content')
      ..constructors.add(Constructor((c) => c
        ..requiredParameters.addAll([
          Parameter((p) => p
            ..name = 'name'
            ..toThis = true),
          Parameter((p) => p
            ..name = 'data'
            ..toThis = true),
        ])
        ..optionalParameters.add(Parameter((p) => p
          ..name = 'contentType'
          ..toThis = true
          ..named = true
          ..defaultTo = literalString('application/octet-stream').code))
        ..initializers.add(literal(refer('super')).call([refer('data')]).code)))
      ..fields.addAll([
        Field((f) => f
          ..name = 'data'
          ..type = refer('Uint8List', 'dart:typed_data')
          ..modifier = FieldModifier.final$),
        Field((f) => f
          ..name = 'name'
          ..type = refer('String')
          ..modifier = FieldModifier.final$),
        Field((f) => f
          ..name = 'contentType'
          ..type = refer('String')
          ..modifier = FieldModifier.final$),
      ])),

    // json content
    Class((c) => c
      ..name = "JSONContent"
      ..extend = refer('Content')
      ..constructors.add(Constructor((c) => c
        ..requiredParameters.add(Parameter((p) => p
          ..name = 'data'
          ..toThis = true))
        ..initializers.add(literal(refer('super')).call([
          refer('jsonEncode', 'dart:convert')
              .call([refer('data')]).property('codeUnits')
        ]).code)))
      ..fields.add(Field((f) => f
        ..name = 'data'
        ..type = refer('Map<String, dynamic>')
        ..modifier = FieldModifier.final$))),

    // streamed content
    Class((c) => c
      ..name = "StreamedContent"
      ..extend = refer('Content')
      ..constructors.add(Constructor((c) => c
        ..requiredParameters.addAll([
          Parameter((p) => p
            ..name = 'name'
            ..toThis = true),
          Parameter((p) => p
            ..name = 'data'
            ..toThis = true),
          Parameter((p) => p
            ..name = 'length'
            ..toThis = true),
        ])
        ..optionalParameters.add(Parameter((p) => p
          ..name = 'contentType'
          ..toThis = true
          ..named = true
          ..defaultTo = literalString('application/octet-stream').code))
        ..initializers.add(literal(refer('super')).call([literal([])]).code)))
      ..fields.addAll([
        Field((f) => f
          ..name = 'data'
          ..type = refer('Stream<List<int>>')
          ..modifier = FieldModifier.final$),
        Field((f) => f
          ..annotations.add(refer('override'))
          ..name = 'length'
          ..type = refer('int')
          ..modifier = FieldModifier.final$),
        Field((f) => f
          ..name = 'name'
          ..type = refer('String')
          ..modifier = FieldModifier.final$),
        Field((f) => f
          ..name = 'contentType'
          ..type = refer('String')
          ..modifier = FieldModifier.final$),
      ])
      ..methods.addAll([
        Method((m) => m
          ..annotations.add(refer('override'))
          ..name = 'raw'
          ..type = MethodType.getter
          ..returns = refer('List<int>')
          ..body = refer('Exception')
              .call([
                literalString(
                    'Do not call raw on streamed content: Use `data` instead')
              ])
              .thrown
              .code)
      ])),
  ];

  return classes;
}

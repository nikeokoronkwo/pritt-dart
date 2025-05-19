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
        ..modifier = FieldModifier.final$))),

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
            ..type = refer('String')))
        // override
        ),

    // binary content
    Class((c) => c
      ..name = "BinaryContent"
      ..extend = refer('Content')
      ..constructors.add(Constructor((c) => c
        ..requiredParameters.add(Parameter((p) => p
          ..name = 'data'
          ..toThis = true))
        ..initializers.add(literal(refer('super')).call([refer('data')]).code)))
      ..fields.add(Field((f) => f
        ..name = 'data'
        ..type = refer('Uint8List', 'dart:typed_data')))),

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
        ..type = refer('Map<String, dynamic>')))),

    // streamed content
    Class((c) => c
      ..name = "StreamedContent"
      ..extend = refer('Content')
      ..constructors.add(Constructor((c) => c
        ..requiredParameters.add(Parameter((p) => p
          ..name = 'data'
          ..toThis = true))
        ..initializers.add(literal(refer('super')).call([literal([])]).code)))
      ..fields.add(Field((f) => f
        ..name = 'data'
        ..type = refer('Stream<List<int>>')))
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

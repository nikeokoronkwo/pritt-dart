import 'dart:js_interop';
import 'package:code_builder/code_builder.dart';
import '../js.dart';
import '../js_helpers.dart';

Iterable<Class> generateBaseClasses(JSRecord<JSString, Schema> schemas,
    {List<String> contentTypes = const []}) {
  List<Class> classes = [
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
        ..type = refer('Map<String, dynamic>'))))
  ];

  return classes;
}

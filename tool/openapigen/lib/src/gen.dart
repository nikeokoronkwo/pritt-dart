import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:code_builder/code_builder.dart';

import 'gen/generate_base_classes.dart';
import 'gen/generate_methods.dart';
import 'js.dart';
import 'js_helpers.dart';

extension SchemaGen on OpenAPIGenResult {
  /// Generates the code for the dart library
  Map<String, String> generateLibrary({String? interfaceName}) {
    // The convention here is:
    // We start with a single file project

    // generate schema classes
    final schemaClasses = _generateClasses(schemas);

    // generate client class
    final clientClass = Class(
      (c) => c
        ..abstract = true
        ..modifier = ClassModifier.interface
        ..name = "${interfaceName ?? 'Pritt'}Interface"
        ..docs.addAll(
          [if (docs != null) docs!].map((d) {
            return const LineSplitter()
                .convert(d)
                .map((d) => '/// $d')
                .join('\n');
          }),
        )
        ..methods.addAll(generateMethods(schemas, methods)),
    );

    final lib = Library(
      (l) => l
        ..ignoreForFile.addAll([
          'non_constant_identifier_names',
          'directives_ordering',
          'constant_identifier_names',
          'package_access',
        ])
        ..directives.add(
          Directive.import('package:json_annotation/json_annotation.dart'),
        )
        ..directives.add(Directive.part('interface.g.dart'))
        ..body.addAll([
          ...generateBaseClasses(schemas),
          ...schemaClasses.values,
          clientClass,
        ]),
    );

    return {
      'interface.dart':
          '${lib.accept(DartEmitter.scoped(useNullSafetySyntax: true, orderDirectives: true))}',
    };
  }
}

Map<String, Spec> _generateClasses(JSRecord<JSString, Schema> schemas) {
  final Map<String, Spec> specs = {};
  entriesFromRecord(schemas).toDart.forEach((schemaTuple) {
    _generateSpecFromSchema(
      schemaTuple[1] as JSObject,
      schemaTuple[0].dartify() as String,
      componentSpecs: specs,
    );
  });

  return specs;
}

Reference _generateSpecFromSchema<T extends Spec>(
  Schema schema,
  String name, {
  Map<String, Spec>? componentSpecs,
  bool? required,
}) {
  componentSpecs ??= {};

  if (schema.hasProperty('nullable'.toJS).toDart) {
    required = !(schema.getProperty('nullable'.toJS) as JSBoolean).toDart;
  } else {
    required ??= true;
  }

  if (componentSpecs.containsKey(name)) {
    return TypeReference(
      (t) => t
        ..symbol = switch (componentSpecs![name]) {
          final Enum e => e.name,
          final Class c => c.name,
          _ => throw Exception('Unknown'),
        }
        ..isNullable = !(required ?? true),
    );
  }

  if (schema.hasProperty('oneOf'.toJS).toDart) {
    final obj = schema.getProperty('oneOf'.toJS) as JSArray<JSObject>;

    // nested enums
    if (obj.toDart.any((o) => o.hasProperty('enum'.toJS).toDart)) {
      // enum
      final basicEnumValues = obj.toDart
          .where((o) => o.hasProperty('enum'.toJS).toDart)
          .map(
            (o) => (o.getProperty('enum'.toJS) as JSArray<JSString>).toDart.map(
              (v) => v.toDart,
            ),
          )
          .reduce((previous, current) => [...previous, ...current]);

      final enumeration = Enum(
        (e) => e
          ..annotations.add(
            refer('JsonEnum').call([], {'valueField': literalString('value')}),
          )
          ..constructors.add(
            Constructor(
              (c) => c
                ..constant = true
                ..requiredParameters.add(
                  Parameter(
                    (p) => p
                      ..name = 'value'
                      ..toThis = true,
                  ),
                ),
            ),
          )
          ..fields.add(
            Field(
              (f) => f
                ..name = 'value'
                ..type = refer('String'),
            ),
          )
          ..name = schema.getProperty('title'.toJS).dartify() as String? ?? name
          ..values.addAll(
            basicEnumValues.map((ev) {
              return EnumValue(
                (val) => val
                  ..name = ev
                  ..arguments.add(literalString(ev)),
              );
            }),
          ),
      );

      componentSpecs.putIfAbsent(name, () => enumeration);

      return refer(enumeration.name + (required ? '' : '?'));
    }
  }

  if (schema.hasProperty('enum'.toJS).toDart) {
    final enumValues = schema.getProperty('enum'.toJS) as JSArray<JSString>;
    final dartifiedEnumValues = enumValues.toDart.map((v) => v.toDart);
    // let's try enum
    final enumeration = Enum(
      (e) => e
        ..annotations.add(
          refer('JsonEnum').call([], {'valueField': literalString('value')}),
        )
        ..constructors.add(
          Constructor(
            (c) => c
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'value'
                    ..toThis = true,
                ),
              ),
          ),
        )
        ..fields.add(
          Field(
            (f) => f
              ..name = 'value'
              ..type = refer('String'),
          ),
        )
        ..name = schema.getProperty('title'.toJS).dartify() as String? ?? name
        ..values.addAll(
          dartifiedEnumValues.map((ev) {
            return EnumValue(
              (val) => val
                ..name = ev
                ..arguments.add(literalString(ev)),
            );
          }),
        ),
    );

    componentSpecs.putIfAbsent(name, () => enumeration);

    return refer(enumeration.name + (required ? '' : '?'));
  }

  if (schema.hasProperty('additionalProperties'.toJS).toDart &&
      schema.getProperty('additionalProperties'.toJS) != false.toJS) {
    // map
    final valueSchema =
        schema.getProperty('additionalProperties'.toJS) as JSObject;

    return TypeReference(
      (t) => t
        ..symbol = 'Map'
        ..types.addAll([
          refer('String'),
          _generateSpecFromSchema(
            valueSchema,
            valueSchema.getProperty('title'.toJS).dartify() as String? ??
                "${name}Val",
            componentSpecs: componentSpecs,
          ),
        ])
        ..isNullable = !(required ?? true),
    );
  }

  if (schema.hasProperty('type'.toJS).toDart) {
    switch (schema.getProperty('type'.toJS).dartify() as String) {
      case 'string':
      case 'number':
      case 'integer':
      case 'boolean':
        return TypeReference(
          (t) => t
            ..symbol =
                switch (schema.getProperty('type'.toJS).dartify() as String) {
                  'string' => 'String',
                  'number' => 'num',
                  'integer' => 'int',
                  'boolean' => 'bool',
                  _ => 'Object',
                } +
                ((required ?? true) ? '' : '?'),
        );
      case 'array':
        if (!schema.hasProperty('items'.toJS).toDart) {
          print("Not supported any of arrays");
          return refer('List');
        } else {
          final itemSchema = schema.getProperty('items'.toJS) as JSObject;
          return TypeReference(
            (t) => t
              ..symbol = 'List'
              ..isNullable = true
              ..types.add(
                _generateSpecFromSchema(
                  itemSchema,
                  itemSchema.getProperty('title'.toJS).dartify() as String? ??
                      "${name}Item",
                  componentSpecs: componentSpecs,
                ),
              ),
          );
        }
      case 'object':
        break;
      default:
        // nothing
        break;
    }
  } else {
    return refer('dynamic');
  }

  final properties =
      schema.getProperty('properties'.toJS) as JSRecord<JSString, JSObject>;
  final requiredProperties = schema.hasProperty('required'.toJS).toDart
      ? schema.getProperty('required'.toJS) as JSArray<JSString>
      : <String>[].jsify() as JSArray<JSString>;

  final fields = <Field>[];
  final constructorParams = <Parameter>[];

  entriesFromRecord(properties).toDart
      .map((k) => (k[0].dartify() as String, k[1] as JSObject))
      .forEach((v) {
        final name = v.$1;
        final obj = v.$2;
        final propIsRequired = requiredProperties.toDart
            .map((v) => v.toDart.toLowerCase())
            .contains(name.toLowerCase());
        final type = _generateSpecFromSchema(
          obj,
          obj.getProperty('title'.toJS).dartify() as String? ?? name,
          componentSpecs: componentSpecs,
          required: propIsRequired,
        );

        fields.add(
          Field(
            (f) => f
              ..name = name
              ..modifier = FieldModifier.final$
              ..type = type,
          ),
        );

        constructorParams.add(
          Parameter(
            (p) => p
              ..name = name
              ..named = true
              ..toThis = true
              ..required = propIsRequired
              ..defaultTo =
                  !propIsRequired && type.symbol.toString().startsWith('List')
                  ? const Code('const []')
                  : null,
          ),
        );
      });

  final classForSchema = Class(
    (c) => c
      // JSON serializable
      ..annotations.add(
        refer('JsonSerializable').call([], {'includeIfNull': literalFalse}),
      )
      ..name = name
      // main constructor
      ..constructors.add(
        Constructor(
          (ctor) => ctor..optionalParameters.addAll(constructorParams),
        ),
      )
      ..constructors.add(
        Constructor(
          (c) => c
            ..factory = true
            ..name = "fromJson"
            ..requiredParameters.add(
              Parameter(
                (p) => p
                  ..name = 'json'
                  ..type = TypeReference(
                    (t) => t
                      ..symbol = 'Map'
                      ..types.addAll([refer('String'), refer('dynamic')]),
                  ),
              ),
            )
            ..lambda = true
            ..body = refer(
              '_\$${name}FromJson',
            ).call([literal(refer('json'))]).code,
        ),
      )
      ..fields.addAll(fields)
      ..methods.addAll([
        // toJson
        Method(
          (m) => m
            ..name = "toJson"
            ..returns = TypeReference(
              (t) => t
                ..symbol = 'Map'
                ..types.addAll([refer('String'), refer('dynamic')]),
            )
            ..lambda = true
            ..body = refer(
              '_\$${name}ToJson',
            ).call([literal(refer('this'))]).code,
        ),
      ]),
  );

  componentSpecs.putIfAbsent(name, () => classForSchema);

  return TypeReference(
    (t) => t
      ..symbol = classForSchema.name
      ..isNullable = !(required ?? true),
  );
}

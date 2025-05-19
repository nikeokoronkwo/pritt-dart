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
    final clientClass = Class((c) => c
      ..abstract = true
      ..modifier = ClassModifier.interface
      ..name = "${interfaceName ?? 'Pritt'}Interface"
      ..docs.addAll([
        if (docs != null) docs!,
      ].map((d) {
        return const LineSplitter().convert(d).map((d) => '/// $d').join('\n');
      }))
      ..methods.addAll(generateMethods(schemas, methods)));

    final lib = Library((l) => l
      ..body.addAll([
        ...generateBaseClasses(schemas),
        ...(schemaClasses).values,
        clientClass
      ]));

    return {'interface.dart': '${lib.accept(DartEmitter.scoped())}'};
  }
}

Map<String, Class> _generateClasses(JSRecord<JSString, Schema> schemas) {
  Map<String, Class> specs = {};
  entriesFromRecord(schemas).toDart.forEach((schemaTuple) {
    _generateSpecFromSchema(
        schemaTuple[1] as JSObject, schemaTuple[0].dartify() as String,
        componentSpecs: specs);
  });

  return specs;
}

Reference _generateSpecFromSchema<T extends Spec>(Schema schema, String name,
    {Map<String, Class>? componentSpecs, bool? required}) {
  componentSpecs ??= {};

  if (schema.hasProperty('nullable'.toJS).toDart) {
    required = !(schema.getProperty('nullable'.toJS) as JSBoolean).toDart;
  } else required ??= true;

  if (componentSpecs.containsKey(name))
    return refer(componentSpecs[name]!.name);

  print('fada ------> $name - $required');

  if (schema.hasProperty('enum'.toJS).toDart) {
    return refer(required ? 'String' : 'String?');
  }

  if (schema.hasProperty('additionalProperties'.toJS).toDart &&
      schema.getProperty('additionalProperties'.toJS) != false.toJS) {
    // map
    final valueSchema =
        schema.getProperty('additionalProperties'.toJS) as JSObject;

    return TypeReference((t) => t
      ..symbol = 'Map'
      ..types.addAll([
        refer('String'),
        _generateSpecFromSchema(
            valueSchema,
            valueSchema.getProperty('title'.toJS).dartify() as String? ??
                "${name}Val",
            componentSpecs: componentSpecs)
      ]));
  }

  if (schema.hasProperty('type'.toJS).toDart) {
    switch (schema.getProperty('type'.toJS).dartify() as String) {
      case 'string':
      case 'number':
      case 'integer':
      case 'boolean':
        return TypeReference((t) => t
        ..symbol = switch (schema.getProperty('type'.toJS).dartify() as String) {
          'string' => 'String',
          'number' => 'num',
          'integer' => 'int',
          'boolean' => 'bool',
          _ => 'Object'
        } + ((required ?? true) ? '' : '?')
        );
      case 'array':
        if (!schema.hasProperty('items'.toJS).toDart) {
          print("Not supported any of arrays");
          return refer('List');
        } else {
          final itemSchema = schema.getProperty('items'.toJS) as JSObject;
          return TypeReference((t) => t
            ..symbol = 'List' 
            ..types.add(_generateSpecFromSchema(
                itemSchema,
                itemSchema.getProperty('title'.toJS).dartify() as String? ??
                    "${name}Item",
                componentSpecs: componentSpecs))
            ..isNullable = !(required ?? true));
        }
      case 'object':
        break;
      default:
        // nothing
        break;
    }
  } else
    return refer('dynamic');

  final properties =
      schema.getProperty('properties'.toJS) as JSRecord<JSString, JSObject>;
  final requiredProperties =
      schema.hasProperty('required'.toJS).toDart ? schema.getProperty('required'.toJS) as JSArray<JSString> :
      <String>[].jsify() as JSArray<JSString>;

  final fields = <Field>[];
  final constructorParams = <Parameter>[];

  entriesFromRecord(properties)
      .toDart
      .map((k) => (k[0].dartify() as String, k[1] as JSObject))
      .forEach((v) {
    final name = v.$1;
    final obj = v.$2;
    final propIsRequired =
        requiredProperties.toDart.map((v) => v.toDart.toLowerCase()).contains(name.toLowerCase());
    var type = _generateSpecFromSchema(
          obj, obj.getProperty('title'.toJS).dartify() as String? ?? name,
          componentSpecs: componentSpecs, required: propIsRequired);
    fields.add(Field((f) => f
      ..name = name
      ..modifier = FieldModifier.final$
      ..type = type
    ));

    constructorParams.add(Parameter((p) => p
      ..name = name
      ..named = true
      ..toThis = true
      ..required = propIsRequired
      ..defaultTo = !propIsRequired && type.symbol.toString().startsWith('List') ? Code('const []') : null
    ));
  });

  final classForSchema = Class((c) => c
    ..name = name
    ..constructors.add(Constructor(
        (ctor) => ctor..optionalParameters.addAll(constructorParams)))
    ..fields.addAll(fields));

  componentSpecs.putIfAbsent(name, () => classForSchema);

  print('Complete $name\n');

  return TypeReference((t) => t
    ..symbol = classForSchema.name + ((required ?? true) ? '' : '?')
  );
}

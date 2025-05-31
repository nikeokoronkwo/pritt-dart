
import 'package:args/args.dart';
import 'package:node_io/node_io.dart';
import 'package:pritt_openapi_gen/src/gen.dart';
import 'package:pritt_openapi_gen/src/js.dart';
import 'package:pritt_openapi_gen/src/node_helpers.dart';

final argParser = ArgParser()
  ..addOption('js-parser-file',
      abbr: 'j',
      defaultsTo: './main.js',
      help: 'The JS File containing the parsing logic')
  ..addOption('out', abbr: 'o', help: 'The output directory')
  ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help');

String get usage => '''
Usage: openapigen <file>

<file> must be an openapi spec (.json or .yaml)
''';

void main(List<String> args) async {
  try {
    final results = argParser.parse(args);

    if (results.wasParsed('help')) {
      print(usage);
      exit(0);
    }

    // get the file argument
    if (results.rest.isEmpty) {
      print("Provide an argument to get started!");
      print(usage);
      exit(1);
    }

    // read the file using node:io
    final file = File(results.rest[0]).readAsStringSync();

    final lib = await loadJSLib(results['js-parser-file']);

    // send the file to the JS method
    // get the map of the object to generate
    final object = await lib.parseOpenAPIDocumentSource(file);

    // generate using code_builder
    final fileMap = object.generateLibrary();

    // write code
    for (final fileMapEntry in fileMap.entries) {
      final (fileName, fileContents) = (fileMapEntry.key, fileMapEntry.value);

      File(join(results['out'] ?? '.', fileName))
          .writeAsStringSync(fileContents);
    }

    print("Generated types at ${results['out'] ?? '.'}");

    exit(0);
  } catch (e, stackTrace) {
    print(e);
    print(stackTrace);
    exit(1);
  }
}

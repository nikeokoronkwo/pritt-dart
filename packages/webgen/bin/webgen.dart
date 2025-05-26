

import 'dart:js_interop';

import 'package:args/args.dart';
import 'package:node_io/node_io.dart';
import 'package:node_interop/path.dart';
import 'package:pritt_webgen/src/js/fs.dart';
import 'package:pritt_webgen/src/js/handlebars.dart' as handlebars;
import 'package:pritt_webgen/src/js/js.dart';

final argParser = ArgParser()
..addOption('input', abbr: 'i', help: 'The path to the input web dir', defaultsTo: 'web')
..addOption('output', abbr: 'o', help: 'The output dir to produce the web code', defaultsTo: 'web-ref')
..addOption('template', abbr: 't', help: 'The template directory (i.e the dir where the template is)', defaultsTo: 'web/template')
..addOption('config', abbr: 'c', help: 'The configuration file to read the template config')
..addFlag('help', abbr: 'h', negatable: false, help: 'Show help information')
..addOption('js-file', abbr: 'j', help: 'The JS File containing utilities used', defaultsTo: './index.js');


void main(List<String> args) async {
  final argResults = argParser.parse(args);
  if (argResults.wasParsed('help')) print(argParser.usage);

  // await importModule(argResults['js-file']).toDart;

  final dir = Directory(argResults['input']);
  final templateDir = Directory(argResults['template']);

  final outDir = Directory(argResults['output']);

  // copy over files
  final files = (await readdir(dir.path, FSReadDirOptions(encoding: 'utf8', recursive: true, withFileTypes: true)).toDart).toDart;
  for (final file in files) {
    final srcPath = path.join(dir.path, path.relative(dir.path, file.parentPath), file.name);
    final destPath = path.join(outDir.path, path.relative(dir.path, file.parentPath), file.name);

    if (!path.dirname(srcPath).split(path.sep).contains('node_modules')) {
      if (file.isFile()) {
        try {
          await mkdir(path.dirname(destPath), FSMkdirOptions(recursive: true)).toDart;
        } catch (e) {
          // ignore
        }
        await (copyFile(srcPath, destPath).toDart);
      }
    }
  }

  // perform transformation
  

  final foo = handlebars.compileString('Hello {{ nono }}');

  print(foo.callAsFunction('fee'.toJS));
  print(foo.callAsFunction('nono'.toJS));
  print(foo.callAsFunction({'nono': 'nene'}.jsify()));
  print(foo.callAsFunction({'nono': 'nae nae'}.jsify()));
  print(foo.callAsFunction({'nono': 'michael'}.jsify()));


  // if template dir is in new dir, remove
  if (isSubDir(dir.path, templateDir.path)) {
    final relPath = path.relative(dir.path, templateDir.path);
    final newPath = path.join(outDir.path, relPath);

    Directory(newPath).deleteSync(recursive: true);
  }
}

bool isSubDir(String parent, String child) {
  final relative = path.relative(
    path.resolve(parent),
    path.resolve(child)
  );

  return !relative.startsWith('..') && !path.isAbsolute(relative) && relative.isNotEmpty;
}
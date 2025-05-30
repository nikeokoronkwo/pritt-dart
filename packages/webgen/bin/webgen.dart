import 'dart:convert';
import 'dart:js_interop';

import 'package:args/args.dart';
import 'package:node_io/node_io.dart';
import 'package:node_interop/path.dart';
import 'package:pritt_webgen/src/config.dart';
import 'package:pritt_webgen/src/js/child_process.dart';
import 'package:pritt_webgen/src/js/fs.dart';
import 'package:pritt_webgen/src/js/handlebars.dart' as handlebars;
import 'package:pritt_webgen/src/js/iterator.dart';
import 'package:pritt_webgen/src/js/js.dart';
import 'package:pritt_webgen/src/transform.dart';
import 'package:yaml/yaml.dart';

final argParser = ArgParser()
  ..addOption('input',
      abbr: 'i', help: 'The path to the input web dir', defaultsTo: 'web')
  ..addOption('output',
      abbr: 'o',
      help: 'The output dir to produce the web code',
      defaultsTo: 'web-ref')
  ..addOption('template',
      abbr: 't',
      help: 'The template directory (i.e the dir where the template is)',
      defaultsTo: 'web/template')
  ..addOption('config',
      abbr: 'c',
      help: 'The configuration file to read the template config',
      defaultsTo: 'template.yaml')
  ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help information')
  ..addFlag('watch', abbr: 'w', negatable: false, help: 'Watch the input directory for changes')
  ..addOption('js-file',
      abbr: 'j',
      help: 'The JS File containing utilities used',
      defaultsTo: './index.js');

// TODO: Wrap in try-catch to handle errors gracefully
void main(List<String> args) async {
  final argResults = argParser.parse(args);
  if (argResults.wasParsed('help')) print(argParser.usage);

  // await importModule(argResults['js-file']).toDart;

  print('LOG: Getting Arguments...');

  final dir = Directory(argResults['input']);
  final templateDir = Directory(argResults['template']);

  final outDir = Directory(argResults['output']);

  if (outDir.existsSync()) {
    print('LOG: Cleaning up previous build...');
    outDir.deleteSync(recursive: true);
  }

  outDir.createSync();

  print('LOG: Updating Drizzle Schema...');
  execSync('pnpm db:pull',
      ChildProcessExecOptions(encoding: 'utf-8', cwd: dir.path));

  print('LOG: Copying Files...');
  // copy over files
  final files = (await readdir(
              dir.path,
              FSReadDirOptions(
                  encoding: 'utf8', recursive: true, withFileTypes: true))
          .toDart)
      .toDart;
  for (final file in files) {
    final srcPath = path.join(
        dir.path, path.relative(dir.path, file.parentPath), file.name);
    final destPath = path.join(
        outDir.path, path.relative(dir.path, file.parentPath), file.name);

    if (!path.dirname(srcPath).split(path.sep).contains('node_modules')) {
      if (file.isFile()) {
        try {
          await mkdir(path.dirname(destPath), FSMkdirOptions(recursive: true))
              .toDart;
        } catch (e) {
          // ignore
        }
        await (copyFile(srcPath, destPath).toDart);
      }
    }
  }

  // run install
  print('LOG: Installing Dependencies...');
  execSync(
      'pnpm i', ChildProcessExecOptions(cwd: outDir.path, encoding: 'utf-8'));

  print('LOG: Reading Configuration...');
  // get configuration
  final configFile = File(argResults['config'] == 'template.yaml'
      ? path.join(dir.path, 'template.yaml')
      : argResults['config']);

  if (!configFile.existsSync()) {
    print('Configuration file not found: ${configFile.path}');
    return;
  }

  final configContent = await configFile.readAsString();
  final config = WebGenTemplateConfig.fromJson(
      jsonDecode(jsonEncode(loadYaml(configContent))));

  // perform transformation
  // final templateFiles = (await readdir(
  //             templateDir.path,
  //             FSReadDirOptions(
  //                 encoding: 'utf8', recursive: true, withFileTypes: true))
  //         .toDart)
  //     .toDart;
  final result = await transformTemplates(dir.path, templateDir.path, outDir.path, config);

  // if template dir is in new dir, remove
  if (isSubDir(dir.path, templateDir.path)) {
    final relPath = path.relative(dir.path, templateDir.path);
    final newPath = path.join(outDir.path, relPath);

    await Directory(newPath).delete(recursive: true);
  }

  if (argResults.wasParsed('watch')) {
    print('STARTED WATCHING FOR CHANGES...');
    // watch
    final watcher = watch(dir.path, FSWatchOptions(recursive: true));
    // Felicity Smoak: Of course it would, because I am smart
    // Oliver: I can't focus with you blabbing into my ear
    await for (final entry in watcher.toDartStream) {
      final filePath = entry.filename;
      final modification = entry.eventType == 'change';
      print('${entry.eventType} on ${entry.filename}');

      // anyways
      if (filePath != null) {
        final String destPath;
        final isTemplate = path.dirname(filePath).startsWith('template');
        if (isTemplate) {
          destPath = path.join(outDir.path, filePath.split(path.sep).skip(1).join(path.sep));
        } else {
          destPath = path.join(outDir.path, filePath);
        }

        if (modification) {
          // normal mod
          if (isTemplate && path.extname(filePath) == '.hbs') {
            final fileContents = await File(path.join(dir.path, filePath)).readAsString();
            final destContents = handlebars.compileString(fileContents)(result.options);
            await writeFileAsString(destPath.replaceAll('.hbs', ''), destContents).toDart;
          } else {
            await copyFile(path.join(dir.path, filePath), destPath).toDart;
          }
        } else {
          final currentFile = File(path.join(dir.path, filePath));
          if (await currentFile.exists()) {
            // addition
            await copyFile(path.join(dir.path, filePath), destPath).toDart;
          } else {
            // deletion
            await File(destPath).delete();
          }
        }
      }
    }
  }
  print('ALL DONE!');
  print(
      'NOTE: Migrations have not been applied yet. You can apply migrations by running `pnpm db:migrate` in the directory');
}

bool isSubDir(String parent, String child) {
  final relative = path.relative(path.resolve(parent), path.resolve(child));

  return !relative.startsWith('..') &&
      !path.isAbsolute(relative) &&
      relative.isNotEmpty;
}

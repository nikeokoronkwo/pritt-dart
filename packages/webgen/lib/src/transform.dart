import 'dart:convert';
import 'dart:js_interop';

import 'package:node_interop/child_process.dart';
import 'package:node_interop/path.dart';
import 'package:node_io/node_io.dart';

import 'config.dart';
import 'css.dart';
import 'js/fs.dart';
import 'js/gen.dart';
import 'js/handlebars.dart';
import 'js/template.dart';

class TransformationResult {
  TemplateOptions options;

  TransformationResult(this.options);
}

/// Transforms the templates in the input directory using the provided
/// configuration and writes the output to the specified output directory.
Future<TransformationResult> transformTemplates(String inputDir,
    String templateDir, String outputDir, WebGenTemplateConfig config) async {
  // start with generating files
  final templateOptions = TemplateOptions(
      auth: AuthOptions(
          name: config.name,
          title: config.meta?.title ?? config.name,
          magicLink: config.auth.magicLink,
          passkey: config.auth.passkey,
          oauth: OAuthOptions(
            google: config.auth.google,
            github: config.auth.github,
          ),
          admin: true, // TODO: Optional?
          orgs: true));


  // generate auth and db glue code
  await generateAuthAndDb(templateOptions, outputDir);

  // generate css
  await generateTailwindCss(templateOptions, outputDir);

  // continue

  // generate layouts
  final files = (await readdir(
              templateDir,
              FSReadDirOptions(
                  encoding: 'utf8', recursive: true, withFileTypes: true))
          .toDart)
      .toDart;
  for (final file in files.where((f) => f.isFile())) {
    final destPath = path.join(
        outputDir,
        path.relative(templateDir, file.parentPath),
        file.name.replaceAll('.hbs', ''));
    final actualPath = path.join(
        templateDir, path.relative(templateDir, file.parentPath), file.name);

    final actualContents = await File(actualPath).readAsString();
    final destContents = compileString(actualContents)(templateOptions);

    await mkdir(path.dirname(destPath), FSMkdirOptions(recursive: true)).toDart;
    await writeFileAsString(destPath, destContents).toDart;
  }

  // generate index files

  return TransformationResult(templateOptions);
}

/// Generates Tailwind CSS Code
Future<void> generateTailwindCss(TemplateOptions templateOptions, String outputDir) async {
  print("LOG: Generating Tailwind CSS File");
  // generate CSS code
  final cssCode = generateTailwindMainCssFile();
  final cssFileOutput = './assets/css/main.css';

  await mkdir(path.dirname(path.join(outputDir, cssFileOutput)), FSMkdirOptions(recursive: true)).toDart;

  await writeFileAsString(path.join(outputDir, cssFileOutput), cssCode)
      .toDart;

  
}

/// Generates the Auth Code and Glue DB Code (patches due to imcompetencies)
Future<void> generateAuthAndDb(TemplateOptions templateOptions, String outputDir) async {
  // generate config
  final configurationCode = generateAuthConfig(templateOptions.auth).toDart;

  String? authOutPath;
  
  for (final codeMap in configurationCode) {
    final outPath = path.join(outputDir, codeMap.filename);
    if (codeMap.name == 'auth') authOutPath = outPath;
    (await File(outPath).create(recursive: true))
        .writeAsStringSync(codeMap.code);
  }
  
  // run generate migrations
  final v = await Future.sync(() => childProcess.execSync(
      'pnpx @better-auth/cli generate --config ./server/utils/auth.ts --output ./server/db/schema/auth.ts --y',
      ExecOptions(cwd: outputDir)));
  
  // run migrate migrations
  // TODO:
  // read schema file
  final schemaFile = "./server/db/schema.ts";
  
  String schemaFileContents =
      await File(path.join(outputDir, schemaFile)).readAsString();
  
  final lines = const LineSplitter().convert(schemaFileContents);
  lines.insert(0, "import * as auth from './schema/auth'");
  final spreadIndex = lines.indexWhere((i) => i.trim().startsWith('...'));
  lines.insert(spreadIndex, '...auth,');
  
  await writeFileAsString(path.join(outputDir, schemaFile), lines.join('\n'))
      .toDart;
  
  // update the auth code
  // manual patch
  // TODO: File bug and get this fixed
  String authDrizzleCode =
      await File(path.join(outputDir, './server/db/schema/auth.ts'))
          .readAsString();
  authDrizzleCode = authDrizzleCode
      .replaceFirst('.default(member)', r".default('member')")
      .replaceFirst('.default(pending)', r".default('pending')")
      .replaceAll('=> user.id', '=> auth_user.id');
  final adcLines = const LineSplitter().convert(authDrizzleCode);
  adcLines.insert(0, 'import { users } from "./schema"');
  authDrizzleCode = adcLines.join('\n');
  
  await writeFileAsString(
          path.join(outputDir, './server/db/schema/auth.ts'), authDrizzleCode)
      .toDart;
  
  // generate drizzle migrations
  final _ = await Future.sync(() =>
      childProcess.execSync('pnpm db:generate', ExecOptions(cwd: outputDir)));
}

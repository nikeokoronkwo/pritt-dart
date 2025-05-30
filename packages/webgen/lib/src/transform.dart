import 'dart:convert';
import 'dart:js_interop';

import 'config.dart';
import 'js/fs.dart';
import 'js/gen.dart';
import 'js/template.dart';
import 'package:node_io/node_io.dart';
import 'package:node_interop/path.dart';
import 'package:node_interop/child_process.dart';

/// Transforms the templates in the input directory using the provided
/// configuration and writes the output to the specified output directory.
Future<void> transformTemplates(String inputDir, String templateDir,
    String outputDir, WebGenTemplateConfig config) async {
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
  // manual patcj
  // TODO: File bug and get this fixed
  String authDrizzleCode =
      await File(path.join(outputDir, './server/db/schema/auth.ts'))
          .readAsString();
  authDrizzleCode = authDrizzleCode
      .replaceFirst('.default(member)', r".default('member')")
      .replaceFirst('.default(pending)', r".default('pending')");

  await writeFileAsString(
          path.join(outputDir, './server/db/schema/auth.ts'), authDrizzleCode)
      .toDart;

  // generate drizzle migrations
  final _ = await Future.sync(() =>
      childProcess.execSync('pnpm db:generate', ExecOptions(cwd: outputDir)));

  // continue

  // generate layouts
  final files = (await readdir(
              templateDir,
              FSReadDirOptions(
                  encoding: 'utf8', recursive: true, withFileTypes: true))
          .toDart)
      .toDart;
  for (final file in files) {
    final destPath = path.join(
        outputDir, path.relative(templateDir, file.parentPath), file.name);

    print(destPath);
  }

  // generate index files
}

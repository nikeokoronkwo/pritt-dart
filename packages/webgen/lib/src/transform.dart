import 'dart:convert';
import 'dart:js_interop';

import 'package:node_interop/child_process.dart';
import 'package:node_interop/path.dart';
import 'package:node_io/node_io.dart';

import 'config.dart';
import 'config/style.dart';
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
Future<TransformationResult> transformTemplates(
  String inputDir,
  String templateDir,
  String outputDir,
  WebGenTemplateConfig config,
) async {
  // start with generating files
  final templateOptions = TemplateOptions(
    name: config.name,
    time: TimeOptions.fromDateTime(DateTime.now()),
    auth: AuthOptions(
      name: config.name,
      title: config.meta?.title ?? config.name,
      magicLink: config.auth.magicLink,
      passkey: config.auth.passkey,
      oauth: OAuthOptions(
        google: config.auth.google,
        github: config.auth.github,
      ),
      admin: true,
      orgs: true,
    ),
  );

  // generate auth and db glue code
  await generateAuthAndDb(templateOptions, outputDir);

  // generate css
  await generateTailwindCss(templateOptions, outputDir, config);

  // generate assets
  await generateAssets(config, outputDir);

  // continue

  // generate layouts
  final files = (await readdir(
    templateDir,
    FSReadDirOptions(encoding: 'utf8', recursive: true, withFileTypes: true),
  ).toDart).toDart;
  for (final file in files.where((f) => f.isFile())) {
    final destPath = path.join(
      outputDir,
      path.relative(templateDir, file.parentPath),
      file.name.replaceAll('.hbs', ''),
    );
    final actualPath = path.join(
      templateDir,
      path.relative(templateDir, file.parentPath),
      file.name,
    );

    final actualContents = await File(actualPath).readAsString();
    final destContents = compileString(actualContents)(templateOptions);

    await mkdir(path.dirname(destPath), FSMkdirOptions(recursive: true)).toDart;
    await writeFileAsString(destPath, destContents).toDart;
  }

  // generate index files

  return TransformationResult(templateOptions);
}

Future<void> generateAssets(
  WebGenTemplateConfig wgtConfig,
  String outputDir,
) async {
  // 1. generate the two svgs

  // start with dir
  final assetsDir = 'assets/svg';

  await mkdir(
    path.join(outputDir, assetsDir),
    FSMkdirOptions(recursive: true),
  ).toDart;

  // get colours
  final accentColour = wgtConfig.style.colours.accent.defaultColour;
  final primaryColour = wgtConfig.style.colours.primary.defaultColour;

  final accentSvg = _svgGen(accentColour);
  final primarySvg = _svgGen(primaryColour);

  await writeFileAsString(
    path.join(outputDir, assetsDir, 'bg-accent.svg'),
    accentSvg,
  ).toDart;
  await writeFileAsString(
    path.join(outputDir, assetsDir, 'bg-primary.svg'),
    primarySvg,
  ).toDart;
}

String _svgGen(String colour) {
  return '''
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svgjs="http://svgjs.dev/svgjs" viewBox="0 0 700 700" width="700" height="700" opacity="1"><defs><filter id="nnnoise-filter" x="-20%" y="-20%" width="140%" height="140%" filterUnits="objectBoundingBox" primitiveUnits="userSpaceOnUse" color-interpolation-filters="linearRGB">
	<feTurbulence type="fractalNoise" baseFrequency="0.071" numOctaves="4" seed="15" stitchTiles="stitch" x="0%" y="0%" width="100%" height="100%" result="turbulence"></feTurbulence>
	<feSpecularLighting surfaceScale="16" specularConstant="1.1" specularExponent="20" lighting-color="$colour" x="0%" y="0%" width="100%" height="100%" in="turbulence" result="specularLighting">
    		<feDistantLight azimuth="3" elevation="129"></feDistantLight>
  	</feSpecularLighting>
  
</filter></defs><rect width="700" height="700" fill="transparent"></rect><rect width="700" height="700" fill="$colour" filter="url(#nnnoise-filter)"></rect></svg>
''';
}

/// Generates Tailwind CSS Code
Future<void> generateTailwindCss(
  TemplateOptions templateOptions,
  String outputDir,
  WebGenTemplateConfig config,
) async {
  print("LOG: Generating Tailwind CSS File");
  // generate CSS code
  final cssCode = generateTailwindMainCssFile(config.style);
  final cssFileOutput = './assets/css/main.css';

  await mkdir(
    path.dirname(path.join(outputDir, cssFileOutput)),
    FSMkdirOptions(recursive: true),
  ).toDart;

  await writeFileAsString(path.join(outputDir, cssFileOutput), cssCode).toDart;
}

/// Generates the Auth Code and Glue DB Code (patches due to imcompetencies)
Future<void> generateAuthAndDb(
  TemplateOptions templateOptions,
  String outputDir,
) async {
  // generate config
  final configurationCode = generateAuthConfig(templateOptions.auth).toDart;

  // String? authOutPath;

  for (final codeMap in configurationCode) {
    final outPath = path.join(outputDir, codeMap.filename);
    // if (codeMap.name == 'auth') authOutPath = outPath;
    (await File(
      outPath,
    ).create(recursive: true)).writeAsStringSync(codeMap.code);
  }

  // run generate migrations
  final _ = await Future.sync(
    () => childProcess.execSync(
      'pnpx @better-auth/cli generate --config ./server/utils/auth.ts --output ./server/db/schema/auth.ts --y',
      ExecOptions(cwd: outputDir),
    ),
  );

  // run migrate migrations
  // read schema file
  final schemaFile = "./server/db/schema.ts";

  String schemaFileContents = await File(
    path.join(outputDir, schemaFile),
  ).readAsString();

  final lines = const LineSplitter().convert(schemaFileContents);
  lines.insert(0, "import * as auth from './schema/auth'");
  final spreadIndex = lines.indexWhere((i) => i.trim().startsWith('...'));
  lines.insert(spreadIndex, '...auth,');

  await writeFileAsString(
    path.join(outputDir, schemaFile),
    lines.join('\n'),
  ).toDart;

  // update the auth code
  // manual patch
  // TODO(nikeokoronkwo): File bug and get this fixed
  String authDrizzleCode = await File(
    path.join(outputDir, './server/db/schema/auth.ts'),
  ).readAsString();
  authDrizzleCode = authDrizzleCode
      .replaceFirst('.default(member)', r".default('member')")
      .replaceFirst('.default(pending)', r".default('pending')")
      .replaceAll('=> user.id', '=> auth_user.id');
  final adcLines = const LineSplitter().convert(authDrizzleCode);
  adcLines.insert(0, 'import { users } from "./schema"');
  authDrizzleCode = adcLines.join('\n');

  await writeFileAsString(
    path.join(outputDir, './server/db/schema/auth.ts'),
    authDrizzleCode,
  ).toDart;

  // generate drizzle migrations
  // ignore: non_constant_identifier_names
  final _ = await Future.sync(
    () =>
        childProcess.execSync('pnpm db:generate', ExecOptions(cwd: outputDir)),
  );
}

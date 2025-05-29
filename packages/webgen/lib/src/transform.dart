

import 'config.dart';
import 'js/gen.dart';
import 'js/template.dart';

/// Transforms the templates in the input directory using the provided
/// configuration and writes the output to the specified output directory.
void transformTemplates(
  String inputDir,
  String templateDir,
  String outputDir,
  WebGenTemplateConfig config
) {
  // start with generating files
  final templateOptions = TemplateOptions(
    auth: AuthOptions()
  );

  // generate config

  // run generate migrations
  
  // run migrate migrations

  // continue

  // generate layouts

  // generate index files

}
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pritt_cli/src/config.dart';

import 'package:pritt_cli/src/project/handler.dart';
import 'package:pritt_common/interface.dart';
import 'package:yaml/yaml.dart';

/// A class used to define the basic details for a project, including its [Workspace]
class Project {

}



/// Gets the current package information given the directory
getPackage(String directory) {}

/// Get the current workspace information for the project being worked on
getWorkspace(String directory, {
  String? config
}) async {
  final dir = Directory(directory);
  // get basic workspace information
  final HandlerManager manager = HandlerManager();

  // in the meantime...
  // check for the vcs
  final VCS vcs = await getVersionControlSystem(dir);

  // check for the pritt configuration
  final PrittConfig? prittConfig = await readPrittConfig(directory, config);

  // check for a .prittignore
  
}

Future<PrittConfig?> readPrittConfig(String dir, String? config) async {
  final File configFile = File(config ?? p.join(dir, 'pritt.yaml'));

  if (await configFile.exists()) return null;

  final configContents = await configFile.readAsString();
  return PrittConfig.fromJson(
    jsonDecode(jsonEncode(loadYaml(configContents)))
  );
}

Future<VCS> getVersionControlSystem(Directory directory) async {
  await for (final entity in directory.list()) {
    if (entity is Directory) {
      switch (p.basename(entity.path)) {
        case '.git':
          return VCS.git;
        case '.svn':
          return VCS.svn;
        case '.hg':
          return VCS.mercurial;
        case '_FOSSIL_':
          return VCS.fossil;
        default:
          continue;
      }
    } else if (entity is File) {
      if (['.fslckout', '.fossil'].contains(p.extension(entity.path))) return VCS.fossil;
    }
  }
  return VCS.other;
}



/// Configure the current project to make use of Pritt
configureWorkspace(String directory) {
  // get the current project workspace

  // get the language of the project

  // check if user is logged in

  // if not logged in,

  // configure for project
}

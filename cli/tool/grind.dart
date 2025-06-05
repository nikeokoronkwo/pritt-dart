import 'dart:io';

import 'package:grinder/grinder.dart';
import 'package:cli_pkg/cli_pkg.dart' as pkg;

void main(List<String> args) {
  // values
  pkg.humanName.value = "Pritt";
  pkg.executables.value = {"pritt": "bin/pritt.dart"};

  pkg.githubUser.fn = () => Platform.environment["GH_USER"];
  pkg.githubPassword.fn = () => Platform.environment["GH_TOKEN"];

  // add tasks and grind
  pkg.addAllTasks();
  grind(args);
}

@DefaultTask("Compile Code and Format")
void all() {}

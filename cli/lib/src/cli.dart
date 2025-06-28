import 'cli/base.dart';
import 'cmd/adapter.dart';
import 'cmd/add.dart';
import 'cmd/configure.dart';
import 'cmd/info.dart';
import 'cmd/login.dart';
import 'cmd/package.dart';
import 'cmd/publish.dart';
import 'cmd/remove.dart';
import 'cmd/unpack.dart';
import 'cmd/yank.dart';

/// Run the command-line interface
Future run(List<String> args) async {
  var runner = PrittCommandRunner(
      'pritt', "A tool for making development easier across projects")
    ..addCommand(AddCommand())
    ..addCommand(RemoveCommand())
    ..addCommand(LoginCommand())
    ..addCommand(InfoCommand())
    ..addCommand(ConfigureCommand())
    ..addCommand(UnpackCommand())
    ..addCommand(PackageCommand())
    ..addCommand(PublishCommand())
    ..addCommand(YankCommand())
    ..addCommand(AdapterCommand())
    ..run(args);
  return runner;
}

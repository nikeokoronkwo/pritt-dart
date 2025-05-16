#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

final SEPARATOR = Platform.isWindows ? "\\" : "/";

final String usage = """
denv: Dart with .env

Usage: ./denv [--cwd <directory>] [.env file] -- <args>

<args> - arguments to pass to command
""";

void main(List<String> args) async {
  if (args.contains('--help')) {
    print(usage);
    exit(0);
  }

  Directory directory;
  if (args.contains('--cwd')) {
    final int dirOption = args.indexOf('--cwd');

    directory = Directory(args[dirOption + 1]);
  } else {
    directory = Directory.current;
  }

  final int separatorIndex = args.indexOf('--');
  if (separatorIndex == -1 || separatorIndex == args.length - 1) {
    print("Provide arguments to get started");
    exit(1);
  }

  final List<String> actualArgs = args.sublist(separatorIndex + 1);
  final List<String> prevArgs = args.sublist(0, separatorIndex);

  final dotEnvFile = File(
      prevArgs.where((arg) => arg.startsWith('.env')).isEmpty
          ? '.env'
          : prevArgs.where((arg) => arg.startsWith('.env')).first);
  final String dotEnv =
      await dotEnvFile.exists() ? await dotEnvFile.readAsString() : "";

  final contents = Map.fromEntries(LineSplitter().convert(dotEnv).map((line) {
    final split = line.split("=");
    return MapEntry(split[0], split[1]);
  }));

  final defineArg = switch (actualArgs[0]) {
    "flutter" => "--dart-define",
    "dart" => "--define",
    _ => throw Exception("denv only works for dart and flutter")
  };

  var executable = actualArgs[0];
  var arguments = [
    if (dotEnv.isNotEmpty)
      ...(contents.entries.map((e) => "$defineArg=${e.key}=${e.value}")),
    ...(actualArgs.skip(1)),
  ];

  print("$executable ${arguments.join(' ')}");

  final process = await Process.start(executable, arguments,
      runInShell: true, workingDirectory: directory.path);

  bool exitBad = false;
  stdin.listen(process.stdin.add);
  process.stdout.transform(utf8.decoder).listen(
        print,
        onDone: () => exit(exitBad ? 1 : 0),
      );
  process.stderr.transform(utf8.decoder).listen(
    (event) {
      exitBad = true;
      stderr.write(event);
    },
    onDone: () => exit(exitBad ? 1 : 0),
  );
}

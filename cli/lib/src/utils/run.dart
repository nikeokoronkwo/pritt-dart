import 'package:io/io.dart';

class Runner {
  ProcessManager manager = ProcessManager();

  Future<int> run(String executable, List<String> args,
      {bool forwardIO = true, String? dir}) async {
    var spawn = await (forwardIO
        ? manager.spawn(executable, args,
            workingDirectory: dir, runInShell: true)
        : manager.spawnDetached(executable, args,
            workingDirectory: dir, runInShell: true));

    return await spawn.exitCode;
  }
}

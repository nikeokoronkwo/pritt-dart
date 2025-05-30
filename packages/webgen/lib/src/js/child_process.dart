@JS('child_process')
library child_process;

import 'dart:js_interop';

import 'js.dart';

@JS('execSync')
external String execSync(String command, [ChildProcessExecOptions? options]);

extension type ChildProcessExecOptions._(JSObject _) implements JSObject {
  external ChildProcessExecOptions(
      {String? cwd, String? env, String? shell, String? encoding = 'utf8'});
  external String? get cwd;
  external JSRecord<JSString, JSString>? get env;
  external String? get shell;
  external String? get encoding;
}

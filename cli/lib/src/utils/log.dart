import 'dart:io' as io;
import 'package:io/ansi.dart';
import 'package:logging/logging.dart' as l;

// ignore: constant_identifier_names
const l.Level VERBOSE = l.Level('VERBOSE', 100);

class Logger {
  factory Logger.verbose() = VerboseLogger;

  Logger();

  stderr(Object msg) {
    io.stderr.writeln(msg);
  }

  void stdout(Object msg) {
    io.stdout.writeln(msg);
  }

  void severe(Object msg, {bool stderr = true, Object? error}) {
    (stderr ? io.stderr : io.stdout).writeln(red.wrap(msg.toString()));
    if (error != null) io.stderr.writeln(error);
  }

  void fine(Object msg) {
    io.stdout.writeln(green.wrap(msg.toString()));
  }

  void info(Object msg) {
    io.stdout.writeln(blue.wrap(msg.toString()));
  }

  void warn(Object msg, {bool warnKey = false}) {
    io.stdout.writeln((warnKey ? 'WARN:' : '') + yellow.wrap(msg.toString())!);
  }

  void verbose(Object msg) {}
}

class VerboseLogger implements Logger {
  final l.Logger _logger;

  @override
  void fine(Object msg) {
    _logger.fine(green.wrap(msg.toString()));
  }

  @override
  void info(Object msg) {
    _logger.info(blue.wrap(msg.toString()));
  }

  @override
  void warn(Object msg, {bool warnKey = false}) {
    _logger.warning(yellow.wrap(msg.toString()));
  }

  @override
  void severe(Object msg, {bool stderr = true, Object? error}) {
    _logger.severe(red.wrap(msg.toString()), error);
  }

  @override
  void stderr(Object msg) {
    io.stderr.writeln(msg);
  }

  @override
  void stdout(Object msg) {
    io.stdout.writeln(msg);
  }

  @override
  verbose(Object msg) {
    _logger.log(VERBOSE, styleDim.wrap(msg.toString()));
  }

  VerboseLogger() : _logger = l.Logger('pritt') {
    if (!l.hierarchicalLoggingEnabled) l.hierarchicalLoggingEnabled = true;

    _logger.level = l.Level.ALL;
    _logger.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }
}

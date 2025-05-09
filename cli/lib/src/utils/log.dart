import 'dart:io' as io;
import 'package:io/ansi.dart';
import 'package:logging/logging.dart' as l;

// ignore: constant_identifier_names
const l.Level VERBOSE = l.Level('VERBOSE', 100);

class Logger {
  factory Logger.verbose() = VerboseLogger;

  Logger();

  stderr(Object msg) {}
  void stdout(Object msg) {
    io.stdout.writeln(msg);
  }

  void severe(Object msg, {bool stderr = true, Object? error}) {
    io.stdout.writeln(red.wrap(msg.toString()));
  }

  fine(Object msg) {}
  info(Object msg) {}
  verbose(Object msg) {}
}

class VerboseLogger implements Logger {
  final l.Logger _logger;

  @override
  fine(Object msg) {}

  @override
  info(Object msg) {}

  @override
  void severe(Object msg, {bool stderr = true, Object? error}) {
    _logger.severe(red.wrap(msg.toString()), error);
  }

  @override
  stderr(Object msg) {}

  @override
  void stdout(Object msg) {}

  @override
  verbose(Object msg) {
    _logger.log(VERBOSE, styleDim.wrap(msg.toString()));
  }

  VerboseLogger() : _logger = l.Logger('devenv') {
    _logger.level = l.Level.ALL;
    _logger.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }
}

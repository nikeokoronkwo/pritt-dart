// ignore_for_file: constant_identifier_names

class AdapterException implements Exception {
  final String message;

  final Object? source;
  AdapterException(this.message, {this.source}) : super();
}

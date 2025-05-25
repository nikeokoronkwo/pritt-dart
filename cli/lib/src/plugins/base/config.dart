import 'package:pritt_common/interface.dart';

/// A configuration object for a plugin
class Config {
  final String name;
  final String version;
  final String? description;
  final Author author;
  final String? license;
  final bool? private;

  const Config(
      {required this.name,
      required this.version,
      this.description,
      required this.author,
      this.license,
      this.private = false});
}

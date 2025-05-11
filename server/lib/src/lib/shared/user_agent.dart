import 'package:pritt_server/src/lib/shared/version.dart';

class UserAgent {
  /// The name of the user agent
  final String name;

  /// The version on the user agent
  final String version;

  /// The raw user agent string
  final String? _raw;

  /// The raw user agent string
  @override
  String toString() {
    return _raw ?? "$name $version";
  }

  const UserAgent._({
    required this.name,
    required this.version,
    String? raw,
  }) : _raw = raw;

  /// Create a user agent from parsing the raw string
  factory UserAgent.fromRaw(String raw) {
    if (raw.isEmpty) {
      throw Exception("Empty user agent");
    }

    final parts = raw.split(' ');
    if (parts[0].contains('/')) {
      final [name, version] = parts[0].split('/');
      return UserAgent._(name: name, version: version, raw: raw);
    }
    
    final version = parts.indexWhere((i) => Version.tryParse(i) != null);
    if (version == -1) {
      return UserAgent._(name: raw, version: '', raw: raw);
    }
    final name = parts.sublist(0, version).join(' ');

    return UserAgent._(name: name, version: parts[version], raw: raw);
  }
}

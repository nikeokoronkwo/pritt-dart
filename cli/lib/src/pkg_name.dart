import 'package:pritt_common/functions.dart';

typedef PkgRepName = ({String name, String? scope, String? version});

PkgRepName parsePackageInfo(String raw) {
  final String identifier;
  final String? version;
  String splitStr = raw;
  if (raw.startsWith('@')) {
    // scoped
    splitStr = raw.substring(1);
  }

  final [first, ...rest] = splitStr.split('@');

  identifier = first;

  if (rest.isEmpty) {
    version = null;
  } else {
    version = rest.first;
  }

  final (name, scope: scope) = parsePackageName(identifier);

  return (name: name, scope: scope, version: version);
}

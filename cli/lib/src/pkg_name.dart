import '../../../packages/common/lib/functions.dart';

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

  identifier = raw.startsWith('@') ? '@$first' : first;

  if (rest.isEmpty) {
    version = null;
  } else {
    version = rest.join('@');
  }

  final (name, scope: scope) = parsePackageName(identifier);

  return (name: name, scope: scope, version: version);
}

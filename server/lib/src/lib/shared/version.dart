enum PreReleaseType {
  alpha,
  beta,
  rc,
  dev,
  unknown,
}

class Version {
  final int major;
  final int minor;
  final int patch;
  final String? preRelease;
  final String? build;

  Version(
    this.major,
    this.minor,
    this.patch, {
    this.preRelease,
    this.build,
  });

  static final _semVerRegExp = RegExp(r'^(0|[1-9]\d*)\.' // major
      r'(0|[1-9]\d*)\.' // minor
      r'(0|[1-9]\d*)' // patch
      r'(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?' // prerelease
      r'(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$' // build metadata
      );

  factory Version.parse(String input) {
    final match = _semVerRegExp.firstMatch(input.trim());
    if (match == null) {
      throw FormatException('Invalid semantic version: $input');
    }

    return Version(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      preRelease: match.group(4),
      build: match.group(5),
    );
  }

  static Version? tryParse(String input) {
    try {
      return Version.parse(input);
    } catch (e) {
      return null;
    }
  }

  PreReleaseType get preReleaseType {
    if (preRelease == null) return PreReleaseType.unknown;

    final lower = preRelease!.toLowerCase();
    if (lower.startsWith('alpha')) return PreReleaseType.alpha;
    if (lower.startsWith('beta')) return PreReleaseType.beta;
    if (lower.startsWith('rc')) return PreReleaseType.rc;
    if (lower.startsWith('dev')) return PreReleaseType.dev;

    return PreReleaseType.unknown;
  }

  bool isPreRelease() {
    return preRelease != null && preRelease!.isNotEmpty;
  }

  bool isPreProduction() {
    return major == 0;
  }

  @override
  String toString() {
    final buffer = StringBuffer('$major.$minor.$patch');
    if (preRelease != null) buffer.write('-$preRelease');
    if (build != null) buffer.write('+$build');
    return buffer.toString();
  }
}

enum PreReleaseType {
  alpha,
  beta,
  rc,
  dev,
  unknown,
}

class Version implements Comparable<Version> {
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

  List<String> _splitPrerelease(String prerelease) =>
      prerelease.split('.');
  
  @override
  int compareTo(Version other) {
    // 1. Compare major, minor, patch
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);

    // 2. Compare prerelease (if both have it)
    if (preRelease == null && other.preRelease != null) return 1; // this is release, other is pre
    if (preRelease != null && other.preRelease == null) return -1; // this is pre, other is release
    if (preRelease != null && other.preRelease != null) {
      final pre1 = _splitPrerelease(preRelease!);
      final pre2 = _splitPrerelease(other.preRelease!);
      final len = pre1.length > pre2.length ? pre2.length : pre1.length;

      for (int i = 0; i < len; i++) {
        final a = pre1[i];
        final b = pre2[i];
        final aNum = int.tryParse(a);
        final bNum = int.tryParse(b);

        if (aNum != null && bNum != null) {
          final cmp = aNum.compareTo(bNum);
          if (cmp != 0) return cmp;
        } else if (aNum == null && bNum == null) {
          final cmp = a.compareTo(b);
          if (cmp != 0) return cmp;
        } else {
          return aNum != null ? -1 : 1; 
        }
      }

      return pre1.length.compareTo(pre2.length);
    }

    return 0;
  }

  bool operator <(Version other) => compareTo(other) < 0;
  bool operator <=(Version other) => compareTo(other) <= 0;
  bool operator >(Version other) => compareTo(other) > 0;
  bool operator >=(Version other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Version &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch &&
      preRelease == other.preRelease &&
      build == other.build;

  @override
  int get hashCode =>
      Object.hash(major, minor, patch, preRelease, build);
}

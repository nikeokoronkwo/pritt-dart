(String name, {String? scope}) parsePackageName(String packageName) {
  final parts = packageName.split('/');
  if (parts.length > 1) {
    if (parts.first.startsWith('@')) {
      // Scoped package
      if (parts.length < 2) {
        throw ArgumentError(
            'Invalid scoped package name: $packageName. Package names should only start with @ and be followed by a package name if scoped.');
      }
      // Return the last part as the package name and the first part as the scope
      if (parts.length > 2) {
        throw ArgumentError(
            'Invalid scoped package name: $packageName, expected format: @scope/package');
      }
      return (parts.last, scope: parts.first.replaceFirst('@', ''));
    } else {
      throw ArgumentError(
          'Invalid package name: $packageName, expected format: @scope/package or package');
    }
  } else {
    return (parts.first, scope: null);
  }
}

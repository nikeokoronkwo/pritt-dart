extension ContainsAllOf on String {
  bool containsAllOf(Iterable<Pattern> patterns) {
    return patterns.every((e) => contains(e));
  }
}

extension Implies on bool {
  bool implies(bool other) {
    return !this || other;
  }
}

extension StreamNullableExtensions<T> on Stream<T?> {
  /// Filters out null values from the stream.
  // TODO: This is a temporary workaround for the issue with Stream<T?>.
  // It should be replaced with a proper solution when available.
  Stream<T> nonNull() {
    return where((element) => element != null).cast<T>();
  }
}

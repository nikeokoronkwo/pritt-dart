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

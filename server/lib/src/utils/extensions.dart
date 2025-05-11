extension ContainsAllOf on String {
  bool containsAllOf(Iterable<Pattern> patterns) {
    return patterns.every((e) => contains(e));
  }
}
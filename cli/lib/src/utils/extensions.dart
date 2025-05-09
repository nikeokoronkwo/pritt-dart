extension IsSingle<T> on Iterable<T> {
  bool get isSingle => singleOrNull != null;
}

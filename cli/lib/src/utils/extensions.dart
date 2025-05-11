extension IsSingle<T> on Iterable<T> {
  bool get isSingle => singleOrNull != null;
}

extension IsUrl on String {
  /// Checks if a given string is a url string
  bool get isUrl => Uri.tryParse(this) != null;
}

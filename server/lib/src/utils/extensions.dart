extension NonNullsMap<K, V> on Map<K, V?> {
  Map<K, V> get nonNulls {
    return Map.fromEntries(
      entries.where((entry) => entry.value != null).cast(),
    );
  }
}

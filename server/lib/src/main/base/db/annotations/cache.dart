class Cacheable {
  /// The duration in seconds for which the data should be cached.
  final int duration;

  /// Indicates whether the cache is enabled or not.
  final bool enabled;

  /// Creates a new instance of [Cacheable].
  const Cacheable({
    this.duration = 3600, // Default to 1 hour
    this.enabled = true,
  });
}

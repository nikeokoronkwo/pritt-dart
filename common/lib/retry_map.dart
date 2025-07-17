import 'dart:async';
import 'dart:collection';

/// A simple map that wraps a [Map] with functionality to
/// retry elements on the given map after a given duration specified by [retry]
///
/// After [retry] is elapsed, [_onRetry] is called on each element of the map,
/// and if it returns true for any value in the map, the map automatically
/// removes the values from it.
///
/// In order for it to work like a map, it extends [MapBase]
class RetryMap<K, V> extends MapBase<K, V> {
  final Map<K, V> _map = {};

  /// The duration between retries
  final Duration retry;
  final FutureOr<bool> Function(K key, V value) _onRetry;

  bool _isActive = true;

  /// Whether the retry loop on the given
  bool get active => _isActive;

  RetryMap({
    Map<K, V>? map,
    this.retry = const Duration(milliseconds: 100),
    required FutureOr<bool> Function(K, V) onRetry,
  }) : _onRetry = onRetry {
    _map.addAll(map ?? {});

    // begin retry loop asynchronously
    unawaited(_beginSync());
  }

  /// Pauses the retry loop on the given map
  void pause() {
    _isActive = false;
  }

  /// Resumes the retry loop on the given map
  ///
  /// Throws a [StateError] if map is already active.
  void resume() {
    if (_isActive) throw StateError('Map is currently active');

    _isActive = true;
    _beginSync();
  }

  Future<void> _beginSync() async {
    while (_isActive) {
      final toRemove = [];
      await Future.delayed(retry, () async {
        for (final entry in _map.entries) {
          if (await _onRetry(entry.key, entry.value)) {
            toRemove.add(entry.key);
          }
        }
      });

      // prefer doing this, as retry maps are used in concurrent environments
      _map.removeWhere((k, v) => toRemove.contains(k));
    }
  }

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? remove(Object? key) => _map.remove(key);
}

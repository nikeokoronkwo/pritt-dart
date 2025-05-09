sealed class Result<T, E> {
  const Result();

  bool get isOk => this is _Ok<T, E>;
  bool get isErr => this is _Err<T, E>;

  T? get ok => switch (this) {
        _Ok(:final value) => value,
        _ => null,
      };

  E? get err => switch (this) {
        _Err(:final error) => error,
        _ => null,
      };

  R match<R>({
    required R Function(T value) ok,
    required R Function(E error) err,
  }) {
    return switch (this) {
      _Ok(:final value) => ok(value),
      _Err(:final error) => err(error),
    };
  }
}

final class _Ok<T, E> extends Result<T, E> {
  final T value;
  const _Ok(this.value);
}

final class _Err<T, E> extends Result<T, E> {
  final E error;
  const _Err(this.error);
}

Result<T, E> Ok<T, E>(T value) => _Ok(value);
Result<T, E> Err<T, E>(E error) => _Err(error);

class _PrimaryKey {
  const _PrimaryKey();
}

const primary = _PrimaryKey();

class _Unique {
  const _Unique();
}

const unique = _Unique();

class ForeignKey<T> {
  final T object;

  final String property;

  const ForeignKey(this.object, {required this.property});
}

class Key {
  final String? name;
  const Key({this.name});
}

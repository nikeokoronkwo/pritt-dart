class Loader<T> {
  final String name;
  final T Function(String contents) load;

  const Loader(this.name, {required this.load});
}
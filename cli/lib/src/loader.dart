class Loader<Ret, Par> {
  final String name;
  final Ret Function(Par) load;

  const Loader(this.name, {required this.load});

  /// Used to create a new [Loader] whose load function is the combination of the current one and [newLoad]
  /// (i.e the contents start with)
  Loader<U, Par> stack<U>(U Function(Ret) newLoad) {
    return Loader(name, load: (a) => newLoad(load(a)));
  }

  /// Used to create a new [Loader] whose load function is called after [prevLoad]
  Loader<Ret, U> stackUnder<U>(Par Function(U) prevLoad) {
    return Loader(name, load: (a) => load(prevLoad(a)));
  }
}

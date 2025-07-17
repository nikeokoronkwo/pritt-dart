(String, String?) parseName(String name) {
  final [first, ...last] = name.split(' ');
  if (last.isEmpty) return (first, null);
  return (first, last.join(' '));
}

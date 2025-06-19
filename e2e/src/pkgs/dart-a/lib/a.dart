

class A {
  String getName() {
    return "A";
  }

  String getNameWithPrefix(String prefix) {
    return "$prefix A";
  }

  String getNameWithSuffix(String suffix) {
    return "A $suffix";
  }

  String getNameWithPrefixAndSuffix(String prefix, String suffix) {
    return "$prefix A $suffix";
  }
}
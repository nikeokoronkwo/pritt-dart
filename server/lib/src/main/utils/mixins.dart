mixin Jsonable on JsonConvertible, JsonDerivable {}

abstract mixin class JsonDerivable {
  factory JsonDerivable.fromJson(Map<String, dynamic> json) {
    throw UnsupportedError('Use a derived class');
  }
}

mixin JsonConvertible {
  Map<String, dynamic> toJson();
}

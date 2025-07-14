// ignore_for_file: constant_identifier_names

import 'mixins.dart';

class MapConvertible with JsonConvertible {
  final Map<String, dynamic> map;

  MapConvertible(this.map);
  @override
  Map<String, dynamic> toJson() => map;
}

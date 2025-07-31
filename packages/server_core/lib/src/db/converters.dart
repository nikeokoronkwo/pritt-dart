import 'package:json_annotation/json_annotation.dart';

import 'schema.dart';

class UserJsonConverter implements JsonConverter<User, Map<String, dynamic>> {
  const UserJsonConverter();

  @override
  User fromJson(Map<String, dynamic> json) {
    throw UnsupportedError('Converting a User from JSON is not supported');
  }

  @override
  Map<String, dynamic> toJson(User object) {
    return {'name': object.name, 'email': object.email};
  }
}

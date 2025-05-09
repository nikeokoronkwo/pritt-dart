/// User credential options: User data stored for indexing
library;

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class UserCredentials {
  /// The URL logged in
}

UserCredentials? getUserCredentials() {}

UserCredentials loginUser() {
  throw UnimplementedError('User not implemented');
}

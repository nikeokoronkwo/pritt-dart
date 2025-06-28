class AuthorizationException implements Exception {
  String? message;
  AuthorizationException([this.message]) : super();
}

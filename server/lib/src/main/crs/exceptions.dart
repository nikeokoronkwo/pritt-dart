// ignore_for_file: constant_identifier_names

class CRSException implements Exception {
  /// The type of the exception
  final CRSExceptionType type;

  /// The message of the exception
  final String message;

  final Object? cause;

  /// The stack trace of the exception
  final StackTrace? stackTrace;

  const CRSException(this.type, this.message, [this.cause, this.stackTrace]);

  @override
  String toString() {
    return 'CRSException: $type: $message\n$stackTrace';
  }
}

enum CRSExceptionType {
  /// The package is not found
  PACKAGE_NOT_FOUND,

  /// The object is not found
  OBJECT_NOT_FOUND,

  /// The version is not found
  VERSION_NOT_FOUND,

  /// The package is not valid
  INVALID_PACKAGE,

  /// The package is not compatible with the current environment
  INCOMPATIBLE_PACKAGE,

  /// The package is not compatible with the current language
  INCOMPATIBLE_LANGUAGE,

  /// The package is not compatible with the current version
  INCOMPATIBLE_VERSION,

  /// Unsupported feature
  UNSUPPORTED_FEATURE,

  /// The item is not found (something other than a package or tarball)
  ITEM_NOT_FOUND
}

class UnauthorizedException implements Exception {
  final String message;
  final String? token;
  final Object? source;
  final UnauthorizedExceptionType? type;
  UnauthorizedException(this.message, {this.token, this.type, this.source});
}

enum UnauthorizedExceptionType { INVALID_TOKEN, UNAUTHORIZED_DEVICE }

class ExpiredTokenException implements Exception {
  final String message;
  final String? token;
  ExpiredTokenException(this.message, {this.token});
}

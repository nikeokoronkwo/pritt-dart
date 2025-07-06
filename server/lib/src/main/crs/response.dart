// ignore_for_file: constant_identifier_names

sealed class CRSResponse<T> {
  final T? body;
  bool get isSuccess => this is CRSSuccessResponse<T>;

  const CRSResponse._(this.body);

  /// A factory constructor for creating a success response
  /// with a body and a status code
  /// [body] is the body of the response
  /// [statusCode] is the status code of the response
  factory CRSResponse.success({
    required T body,
    required int statusCode,
  }) =>
      CRSSuccessResponse(body: body, statusCode: statusCode);

  /// A factory constructor for creating an error response
  /// with an error message and a status code
  factory CRSResponse.error({
    required String error,
    required int statusCode,
  }) =>
      CRSErrorResponse(error: error, statusCode: statusCode, body: null as T?);

  /// A factory constructor for creating an error response
  /// with an error message, a status code and a body
  factory CRSResponse.errorWithBody({
    required String error,
    required int statusCode,
    required T body,
  }) =>
      CRSErrorResponse(error: error, statusCode: statusCode, body: body);
}

class CRSSuccessResponse<T> extends CRSResponse<T> {
  final T _body;

  @override
  T get body => _body;

  const CRSSuccessResponse({
    required T body,
    required int statusCode,
  })  : _body = body,
        super._(body);
}

class CRSErrorResponse<T> extends CRSResponse<T> {
  final String error;
  final int? statusCode;
  final T? _body;

  @override
  T? get body => _body;

  const CRSErrorResponse({
    required this.error,
    this.statusCode,
    required T? body,
  })  : _body = body,
        super._(body);
}

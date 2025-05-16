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
      CRSErrorResponse(error: error, statusCode: statusCode, body: null as T);

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
  @override
  final T body;

  const CRSSuccessResponse({
    required this.body,
    required int statusCode,
  }) : super._(body);
}

class CRSErrorResponse<T> extends CRSResponse<T> {
  final String error;
  final int? statusCode;
  @override
  final T? body;

  const CRSErrorResponse({
    required this.error,
    this.statusCode,
    required this.body,
  }) : super._(body);
}

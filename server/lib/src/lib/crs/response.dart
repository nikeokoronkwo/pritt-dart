// ignore_for_file: constant_identifier_names

class CRSResponse<T> {
  /// the response body
  final T body;

  const CRSResponse(this.body);
  CRSResponse.empty()
      : body = null as T; // TODO: This is a hack, we need to fix this
}

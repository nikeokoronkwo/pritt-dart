/// A Client to the Custom Adapter Service
abstract class CASClient {}

class CASRequest {
  final String id;
  final String method;
  final Map<String, dynamic> params;

  const CASRequest(
      {required this.id, required this.method, required this.params});
}

class CASResponse<T> {
  final String id;
  final T? data;
  final String? error;

  const CASResponse(
      {required this.id, required this.data, required this.error});
}

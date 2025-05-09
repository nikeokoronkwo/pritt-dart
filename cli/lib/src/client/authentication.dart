import 'dart:convert';

typedef QueryParams = Map<String, String>;

abstract class Authentication {
  Future<void> apply(QueryParams queryParams, Map<String, String> headerParams);
}

class OAuth implements Authentication {
  OAuth({this.accessToken = ''});

  String accessToken;

  @override
  Future<void> apply(
    QueryParams queryParams,
    Map<String, String> headerParams,
  ) async {
    if (accessToken.isNotEmpty) {
      headerParams['Authorization'] = 'Bearer $accessToken';
    }
  }
}

typedef HttpBearerAuthProvider = String Function();

class HttpBearerAuth implements Authentication {
  HttpBearerAuth({this.accessToken = ''});

  String accessToken;

  @override
  Future<void> apply(
    QueryParams queryParams,
    Map<String, String> headerParams,
  ) async {
    if (accessToken.isNotEmpty) {
      headerParams['Authorization'] = 'Bearer $accessToken';
    }
  }
}

class HttpBasicAuth implements Authentication {
  HttpBasicAuth({this.username = '', this.password = ''});

  String username;
  String password;

  @override
  Future<void> apply(
    QueryParams queryParams,
    Map<String, String> headerParams,
  ) async {
    if (username.isNotEmpty && password.isNotEmpty) {
      final credentials = '$username:$password';
      headerParams['Authorization'] =
          'Basic ${base64.encode(utf8.encode(credentials))}';
    }
  }
}

// ignore_for_file: flutter_style_todos

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:pritt_common/interface.dart';
import 'package:retry/retry.dart';

import 'client/authentication.dart';
import 'client/base.dart';
import 'constants.dart';
import 'utils/log.dart';

class PrittClient extends ApiClient implements PrittInterface {
  final retryClient = RetryOptions(maxAttempts: 3);
  Map<String, String> get _prittHeaders =>
      {HttpHeaders.userAgentHeader: 'pritt cli'};

  PrittClient({super.url, String? accessToken})
      : super(
            authentication: accessToken == null
                ? null
                : HttpBearerAuth(accessToken: accessToken));

  Future<bool> healthCheck({bool verbose = false}) async {
    try {
      int counter = 0;
      await retryClient.retry(() {
        if (verbose) {
          print('Attempt #${++counter}');
        }
        return request('/', Method.GET, {}, null, null)
            .timeout(Duration(seconds: 2));
      }, retryIf: (e) => e is SocketException || e is TimeoutException);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  FutureOr<AddAdapterResponse> addAdapterWithId(AddAdapterRequest body,
      {required String id}) {
    // TODO: implement addAdapterWithId
    throw UnimplementedError();
  }

  @override
  FutureOr<AddUserResponse> addUserById(AddUserRequest body,
      {required String id}) {
    // TODO: implement addUserById
    throw UnimplementedError();
  }

  // TODO(openapigen): id not nullable
  @override
  FutureOr<AuthResponse> createNewAuthStatus({String? id}) async {
    final response = await requestBasic(
        '/api/auth/new', Method.GET, {'id': id!}, null, null,
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return AuthResponse.fromJson(json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(json.decode(response.body)));
      case 401:
        throw ApiException(
            UnauthorizedError.fromJson(json.decode(response.body)),
            statusCode: 401);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  FutureOr<StreamedContent> getAdapterArchiveWithName({required String name}) {
    // TODO: implement getAdapterArchiveWithName
    throw UnimplementedError();
  }

  @override
  FutureOr<GetAdapterResponse> getAdapterById({required String id}) {
    // TODO: implement getAdapterById
    throw UnimplementedError();
  }

  @override
  FutureOr<GetAdaptersResponse> getAdapters() {
    // TODO: implement getAdapters
    throw UnimplementedError();
  }

  @override
  FutureOr<GetAdaptersByLangResponse> getAdaptersByLang() {
    // TODO: implement getAdaptersByLang
    throw UnimplementedError();
  }

  @override
  FutureOr<AuthPollResponse> getAuthStatus({String? id}) async {
    final response = await requestBasic(
        '/api/auth/status', Method.POST, {'id': id!}, null, null,
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return AuthPollResponse.fromJson(json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(json.decode(response.body)));
      case 405:
        throw ApiException(ExpiredError.fromJson(json.decode(response.body)),
            statusCode: 405);
      case 404:
        throw ApiException(NotFoundError.fromJson(json.decode(response.body)),
            statusCode: 404);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  FutureOr<GetPackagesResponse> getOrgPackages({required String scope}) {
    // TODO: implement getOrgPackages
    throw UnimplementedError();
  }

  @override
  FutureOr<GetScopeResponse> getOrganization({required String scope}) {
    // TODO: implement getOrganization
    throw UnimplementedError();
  }

  @override
  FutureOr<StreamedContent> getPackageArchiveWithName(
      {required String name, String? version}) async {
    final response = await requestStreamed('/api/archive/package/$name',
        Method.GET, {'version': version}, null, null,
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return StreamedContent(
            name, response.stream, response.contentLength ?? 0);
      case 403:
        throw ApiException(
            json.decode(await response.stream.bytesToString())
                as Map<String, dynamic>,
            statusCode: 403);
      case 404:
        throw ApiException(
            NotFoundError.fromJson(
                json.decode(await response.stream.bytesToString())),
            statusCode: response.statusCode);
      case 500:
        throw ApiException.internalServerError(ServerError.fromJson(
            tryDecode(await response.stream.bytesToString())));
      case 401:
        throw ApiException(
            UnauthorizedError.fromJson(
                json.decode(await response.stream.bytesToString())),
            statusCode: 401);
      default:
        throw ApiException(await response.stream.bytesToString(),
            statusCode: response.statusCode);
    }
  }

  @override
  Future<GetPackageResponse> getPackageByName(
      {String? lang, bool? all, required String name}) async {
    final response = await requestBasic('/api/package/$name', Method.GET,
        {'lang': lang, 'all': all?.toString()}, null, null,
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return GetPackageResponse.fromJson(tryDecode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(tryDecode(response.body)));
      case 404:
        throw ApiException(NotFoundError.fromJson(tryDecode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  Future<GetPackageResponse> getPackageByNameWithScope(
      {String? lang,
      bool? all,
      required String scope,
      required String name}) async {
    final response = await requestBasic('/api/package/@$scope/$name',
        Method.GET, {'lang': lang, 'all': all?.toString()}, null, null,
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return GetPackageResponse.fromJson(json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(json.decode(response.body)));
      case 404:
        throw ApiException(NotFoundError.fromJson(json.decode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  Future<GetPackageByVersionResponse> getPackageByNameWithScopeAndVersion(
      {String? lang,
      bool? all,
      required String scope,
      required String name,
      required String version}) async {
    final response = await requestBasic('/api/package/@$scope/$name/$version',
        Method.GET, {'lang': lang, 'all': all?.toString()}, null, null,
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return GetPackageByVersionResponse.fromJson(json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(json.decode(response.body)));
      case 404:
        throw ApiException(NotFoundError.fromJson(json.decode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  Future<GetPackageByVersionResponse> getPackageByNameWithVersion(
      {String? lang,
      bool? all,
      required String name,
      required String version}) async {
    final response = await requestBasic('/api/package/$name/$version',
        Method.GET, {'lang': lang, 'all': all?.toString()}, null, null,
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return GetPackageByVersionResponse.fromJson(json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(json.decode(response.body)));
      case 404:
        throw ApiException(NotFoundError.fromJson(json.decode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  FutureOr<GetPackagesResponse> getPackages(
      {String? index, String? user}) async {
    final response = await requestBasic(
        '/api/packages', Method.GET, {'user': user, 'index': index}, null, null,
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return GetPackagesResponse.fromJson(json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(tryDecode(response.body)));
      case 404:
        throw ApiException(NotFoundError.fromJson(tryDecode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  FutureOr<GetUserResponse> getUserById({required String id}) async {
    final response = await requestBasic(
        '/api/user/$id', Method.GET, {}, null, null,
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return GetUserResponse.fromJson(json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(tryDecode(response.body)));
      case 404:
        throw ApiException(NotFoundError.fromJson(tryDecode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  FutureOr<GetUserResponse> getCurrentUser() async {
    final response = await requestBasic('/api/user', Method.GET, {}, null, null,
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return GetUserResponse.fromJson(json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(tryDecode(response.body)));
      case 404:
        throw ApiException(NotFoundError.fromJson(tryDecode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  FutureOr<GetUsersResponse> getUsers() {
    // TODO: implement getUsers
    throw UnimplementedError();
  }

  @override
  FutureOr<PublishPackageResponse> publishPackage(PublishPackageRequest body,
      {required String name}) async {
    final response = await requestBasic(
        '/api/package/$name', Method.POST, {}, null, json.encode(body.toJson()),
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return PublishPackageResponse.fromJson(json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(json.decode(response.body)));
      case 401:
        throw ApiException(
            UnauthorizedError.fromJson(json.decode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  FutureOr<PublishPackageByVersionResponse> publishPackageVersion(
      PublishPackageByVersionRequest body,
      {required String name,
      required String version}) async {
    final response = await requestBasic('/api/package/$name/$version',
        Method.POST, {}, null, json.encode(body.toJson()),
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return PublishPackageByVersionResponse.fromJson(
            json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(json.decode(response.body)));
      case 401:
        throw ApiException(
            UnauthorizedError.fromJson(json.decode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  FutureOr<PublishPackageResponse> publishPackageWithScope(
      PublishPackageRequest body,
      {required String scope,
      required String name}) async {
    final response = await requestBasic('/api/package/@$scope/$name',
        Method.POST, {}, null, json.encode(body.toJson()),
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return PublishPackageResponse.fromJson(json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(json.decode(response.body)));
      case 401:
        throw ApiException(
            UnauthorizedError.fromJson(json.decode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  FutureOr<PublishPackageByVersionResponse> publishPackageWithScopeAndVersion(
      PublishPackageByVersionRequest body,
      {required String scope,
      required String name,
      required String version}) async {
    final response = await requestBasic('/api/package/@$scope/$name/$version',
        Method.POST, {}, null, json.encode(body.toJson()),
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return PublishPackageByVersionResponse.fromJson(
            json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(json.decode(response.body)));
      case 401:
        throw ApiException(
            UnauthorizedError.fromJson(json.decode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  FutureOr<UploadAdapterResponse> uploadAdapterWithToken(StreamedContent body,
      {String? id}) {
    // TODO: implement uploadAdapterWithToken
    throw UnimplementedError();
  }

  @override
  Future<UploadPackageResponse> uploadPackageWithToken(StreamedContent body,
      {String? id}) async {
    assert(id != null, "ID must be non-null");
    final response = await requestStreamed(
        '/api/package/upload', Method.PUT, {'id': id}, null, body,
        headerParams: _prittHeaders);

    final responseBody = await response.stream.bytesToString();

    switch (response.statusCode) {
      case 200:
      case 204:
        return UploadPackageResponse.fromJson(
            responseBody.isNotEmpty ? json.decode(responseBody) : {});
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(json.decode(responseBody)));
      case 401:
        throw ApiException(
            UnauthorizedError.fromJson(json.decode(responseBody)),
            statusCode: response.statusCode);
      case 402:
        throw ApiException(
            UnauthorizedError.fromJson(json.decode(responseBody)),
            statusCode: response.statusCode);
      case 404:
        throw ApiException(NotFoundError.fromJson(json.decode(responseBody)),
            statusCode: response.statusCode);
      default:
        throw ApiException(responseBody, statusCode: response.statusCode);
    }
  }

  @override
  FutureOr<PublishPackageStatusResponse> getPackagePubStatus(
      {String? id}) async {
    assert(id != null, "ID cannot be null");
    final response = await requestBasic(
        '/api/publish/status', Method.POST, {'id': id}, null, null,
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return PublishPackageStatusResponse.fromJson(
            json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(tryDecode(response.body)));
      case 401:
        throw ApiException(UnauthorizedError.fromJson(tryDecode(response.body)),
            statusCode: response.statusCode);
      case 404:
        throw ApiException(NotFoundError.fromJson(tryDecode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }

  @override
  FutureOr<AuthValidateResponse> validateAuthStatus(AuthValidateRequest body,
      {String? token}) {
    // TODO: implement validateAuthStatus
    throw UnimplementedError();
  }

  @override
  FutureOr<YankAdapterResponse> yankAdapterWithId({required String id}) {
    // TODO: implement yankAdapterWithId
    throw UnimplementedError();
  }

  @override
  FutureOr<YankPackageResponse> yankPackageByName(YankPackageRequest body,
      {required String name}) {
    // TODO: implement yankPackageByName
    throw UnimplementedError();
  }

  @override
  FutureOr<YankPackageResponse> yankPackageByNameWithScope(
      YankPackageRequest body,
      {required String scope,
      required String name}) {
    // TODO: implement yankPackageByNameWithScope
    throw UnimplementedError();
  }

  @override
  FutureOr<YankPackageByVersionRequest> yankPackageByNameWithScopeAndVersion(
      YankPackageByVersionResponse body,
      {required String scope,
      required String name,
      required String version}) {
    // TODO: implement yankPackageByNameWithScopeAndVersion
    throw UnimplementedError();
  }

  @override
  FutureOr<YankPackageByVersionRequest> yankPackageVersionByName(
      YankPackageByVersionResponse body,
      {required String name,
      required String version}) {
    // TODO: implement yankPackageVersionByName
    throw UnimplementedError();
  }

  @override
  FutureOr<AuthDetailsResponse> getAuthDetailsById({required String id}) async {
    final response = await requestBasic(
        '/api/auth/details/$id', Method.GET, {}, null, null,
        headerParams: _prittHeaders);

    switch (response.statusCode) {
      case 200:
        return AuthDetailsResponse.fromJson(json.decode(response.body));
      case 500:
        throw ApiException.internalServerError(
            ServerError.fromJson(tryDecode(response.body)));
      case 404:
        throw ApiException(NotFoundError.fromJson(tryDecode(response.body)),
            statusCode: response.statusCode);
      default:
        throw ApiException(response.body, statusCode: response.statusCode);
    }
  }
}

Map<String, String> tryDecode(String body) {
  try {
    return json.decode(body);
  } catch (e) {
    return {'error': body};
  }
}

/// A single root client that connects to the main pritt url
final rootClient = PrittClient(url: mainPrittInstance);

/// Extension for the Logger to handle exceptions
extension HandleApiException on Logger {
  void describe(ApiException exception) {
    verbose('Error from server: ${exception.statusCode}');
    try {
      verbose('Message: ${exception.body.toJson()}');
    } catch (_) {
      verbose(switch (exception.body) {
        String s => 'Message: $s',
        Error err => 'Message: ${err.toJson()}',
        Object o => 'Unknown Message: $o',
        null => 'No Message'
      });
    }
    severe('The Server returned a status code of ${exception.statusCode}');
    if (this is! VerboseLogger) {
      this.stdout('Run with --verbose to see verbose logging');
    }
  }
}

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
      // TODO: Retry
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
  FutureOr<AuthPollResponse> getAuthStatus({String? id}) {
    // TODO: implement getAuthStatus
    throw UnimplementedError();
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
      {required String name, String? version}) {
    // TODO: implement getPackageArchiveWithName
    throw UnimplementedError();
  }

  @override
  FutureOr<GetPackageResponse> getPackageByName(
      {String? lang, bool? all, required String name}) {
    // TODO: implement getPackageByName
    throw UnimplementedError();
  }

  @override
  FutureOr<GetPackageResponse> getPackageByNameWithScope(
      {String? lang, bool? all, required String scope, required String name}) {
    // TODO: implement getPackageByNameWithScope
    throw UnimplementedError();
  }

  @override
  FutureOr<GetPackageByVersionResponse> getPackageByNameWithScopeAndVersion(
      {String? lang,
      bool? all,
      required String scope,
      required String name,
      required String version}) {
    // TODO: implement getPackageByNameWithScopeAndVersion
    throw UnimplementedError();
  }

  @override
  FutureOr<GetPackageByVersionResponse> getPackageByNameWithVersion(
      {String? lang,
      bool? all,
      required String name,
      required String version}) {
    // TODO: implement getPackageByNameWithVersion
    throw UnimplementedError();
  }

  @override
  FutureOr<GetPackagesResponse> getPackages({String? index, String? user}) {
    // TODO: implement getPackages
    throw UnimplementedError();
  }

  @override
  FutureOr<GetUserResponse> getUserById({required String id}) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  FutureOr<GetUsersResponse> getUsers() {
    // TODO: implement getUsers
    throw UnimplementedError();
  }

  @override
  FutureOr<PublishPackageResponse> publishPackage(PublishPackageRequest body,
      {required String name}) {
    // TODO: implement publishPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<PublishPackageByVersionResponse> publishPackageVersion(
      PublishPackageByVersionRequest body,
      {required String name,
      required String version}) {
    // TODO: implement publishPackageVersion
    throw UnimplementedError();
  }

  @override
  FutureOr<PublishPackageResponse> publishPackageWithScope(
      PublishPackageRequest body,
      {required String scope,
      required String name}) {
    // TODO: implement publishPackageWithScope
    throw UnimplementedError();
  }

  @override
  FutureOr<PublishPackageByVersionResponse> publishPackageWithScopeAndVersion(
      PublishPackageByVersionRequest body,
      {required String scope,
      required String name,
      required String version}) {
    // TODO: implement publishPackageWithScopeAndVersion
    throw UnimplementedError();
  }

  @override
  FutureOr<UploadAdapterResponse> uploadAdapterWithToken(StreamedContent body,
      {String? id}) {
    // TODO: implement uploadAdapterWithToken
    throw UnimplementedError();
  }

  @override
  FutureOr<UploadPackageResponse> uploadPackageWithToken(StreamedContent body,
      {String? id}) {
    // TODO: implement uploadPackageWithToken
    throw UnimplementedError();
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
  FutureOr<GetUserResponse> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  FutureOr<AuthDetailsResponse> getAuthDetailsById({required String id}) {
    // TODO: implement getAuthDetailsById
    throw UnimplementedError();
  }

  @override
  FutureOr<PublishPackageStatusResponse> getPackagePubStatus({String? id}) {
    assert(id != null, "ID cannot be null");
    // TODO: implement getPackagePubStatus
    throw UnimplementedError();
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

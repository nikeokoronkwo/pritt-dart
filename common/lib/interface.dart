// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;
import 'dart:convert' as _i2;
import 'dart:typed_data' as _i1;

class Content {
  const Content(this.raw);

  final List<int> raw;
}

class TextContent extends Content {
  TextContent(this.data) : super(data.codeUnits);

  String data;
}

class BinaryContent extends Content {
  BinaryContent(this.data) : super(data);

  _i1.Uint8List data;
}

class JSONContent extends Content {
  JSONContent(this.data) : super(_i2.jsonEncode(data).codeUnits);

  Map<String, dynamic> data;
}

class AddAdapterRequest {
  AddAdapterRequest();
}

class AddAdapterResponse {
  AddAdapterResponse();
}

class AddUserRequest {
  AddUserRequest();
}

class AddUserResponse {
  AddUserResponse();
}

class PollResponse {
  PollResponse();
}

class AuthPollResponse {
  AuthPollResponse({
    required this.status,
    this.response,
  });

  final String status;

  final PollResponse? response;
}

class AuthResponse {
  AuthResponse({
    required this.token,
    required this.token_expires,
    required this.id,
  });

  final String token;

  final int token_expires;

  final String id;
}

class Error {
  Error({this.error});

  final String? error;
}

class ExpiredError {
  ExpiredError({
    this.error,
    required this.expired_time,
  });

  final String? error;

  final String expired_time;
}

class GetAdapterResponse {
  GetAdapterResponse();
}

class GetAdaptersByLangResponse {
  GetAdaptersByLangResponse();
}

class GetAdaptersResponse {
  GetAdaptersResponse();
}

class GetPackageByVersionResponse {
  GetPackageByVersionResponse();
}

class Author {
  Author({
    required this.name,
    required this.email,
  });

  final String name;

  final String email;
}

class Contributor {
  Contributor({
    required this.name,
    required this.email,
    this.role = const [],
  });

  final String name;

  final String email;

  final List<String> role;
}

class Package {
  Package({
    required this.name,
    required this.description,
    required this.version,
    required this.author,
    this.language,
    required this.created_at,
    this.updated_at,
  });

  final String name;

  final String description;

  final String version;

  final Author author;

  final String? language;

  final String created_at;

  final String? updated_at;
}

class VerbosePackage {
  VerbosePackage({
    required this.name,
    required this.description,
    required this.version,
    required this.author,
    this.language,
    required this.created_at,
    this.updated_at,
    required this.versions,
    required this.authors,
  });

  final String name;

  final String description;

  final String version;

  final Author author;

  final String? language;

  final String created_at;

  final String? updated_at;

  final Map<String, Package> versions;

  final List<Author> authors;
}

class GetPackageResponse {
  GetPackageResponse({
    required this.name,
    required this.latest_version,
    required this.author,
    this.description,
    required this.contributors,
    this.language,
    required this.created_at,
    required this.latest,
    required this.versions,
  });

  final String name;

  final String latest_version;

  final Author author;

  final String? description;

  final List<Contributor> contributors;

  final String? language;

  final String created_at;

  final VerbosePackage latest;

  final Map<String, VerbosePackage> versions;
}

class GetPackagesResponse {
  GetPackagesResponse({
    this.next_url,
    required this.packages,
  });

  final String? next_url;

  final List<Package> packages;
}

class GetUserResponse {
  GetUserResponse();
}

class GetUsersResponse {
  GetUsersResponse();
}

class NotFoundError {
  NotFoundError({
    this.error,
    this.message,
  });

  final String? error;

  final String? message;
}

class PublishPackageByVersionRequest {
  PublishPackageByVersionRequest();
}

class PublishPackageByVersionResponse {
  PublishPackageByVersionResponse();
}

class PublishPackageRequest {
  PublishPackageRequest({
    required this.name,
    required this.version,
    required this.config,
    required this.configFile,
  });

  final String name;

  final String version;

  final Map<String, dynamic> config;

  final String configFile;
}

class PublishPackageResponse {
  PublishPackageResponse();
}

class ServerError {
  ServerError({this.error});

  final String? error;
}

class UnauthorizedError {
  UnauthorizedError({this.error});

  final String? error;
}

class UploadAdapterResponse {
  UploadAdapterResponse();
}

class UploadPackageResponse {
  UploadPackageResponse();
}

class YankAdapterResponse {
  YankAdapterResponse();
}

class YankPackageByVersionResponse {
  YankPackageByVersionResponse();
}

class YankPackageRequest {
  YankPackageRequest({required this.version});

  final String version;
}

class YankPackageResponse {
  YankPackageResponse();
}

/// The Pritt OpenAPI specification used for integrating Pritt with its internal tools (i.e generating schemas for endpoints on the Rust Server and Frontends (CLI and Web)),
/// as well as integrating with other tools.
abstract interface class PrittInterface {
  /// **Get all packages from the Pritt Server**
  /// GET /api/packages
  ///
  /// This GET Request retrieves metadata about all the packages in the registry. To get more information on a specific package use /api/package/{name}
  _i3.FutureOr<GetPackagesResponse> getPackages({String index});

  /// **Get a package from the Pritt Server with the given name**
  /// GET /api/package/{name}
  ///
  /// Throws:
  ///   - [NotFoundError] on status code 404
  _i3.FutureOr<GetPackageResponse> getPackageByName({
    required String name,
    String lang,
    bool all,
  });

  /// **Publish a package to the Pritt Server**
  /// POST /api/package/{name}
  ///
  /// This endpoint is used for publishing packages to Pritt, usually done via the Pritt CLI. Publishing is permanent and cannot be removed
  /// Throws:
  ///   - [UnauthorizedError] on status code 401
  _i3.FutureOr<PublishPackageResponse> publishPackage(
    PublishPackageRequest body, {
    required String name,
    String lang,
    bool all,
  });

  /// **Yank an empty package**
  /// DELETE /api/package/{name}
  ///
  /// This endpoint is for yanking packages from the pritt registry
  /// Throws:
  ///   - [UnauthorizedError] on status code 401
  ///   - [NotFoundError] on status code 404
  _i3.FutureOr<YankPackageResponse> yankPackageByName(
    YankPackageRequest body, {
    required String name,
    String lang,
    bool all,
  });

  /// **Get a package from the Pritt Server with the given name and specified version**
  /// GET /api/package/{name}/{version}
  ///
  /// Throws:
  ///   - [NotFoundError] on status code 404
  _i3.FutureOr<GetPackageByVersionResponse> getPackageByNameAndVersion({
    required String name,
    required String version,
  });

  /// **Publish a package to the Pritt Server with a specified version**
  /// POST /api/package/{name}/{version}
  ///
  /// This endpoint is used for publishing new versions of existing packages to Pritt, usually done via the Pritt CLI. Publishing is permanent and cannot be removed. To publish a new package, use the `/api/package/{name}` POST
  /// Throws:
  ///   - [UnauthorizedError] on status code 401
  _i3.FutureOr<PublishPackageByVersionResponse> publishPackageWithVersion(
    PublishPackageByVersionRequest body, {
    required String name,
    required String version,
  });

  /// **Yank a version of a package **
  /// DELETE /api/package/{name}/{version}
  ///
  /// This endpoint is for yanking a published version of a package from the pritt registry
  /// Throws:
  ///   - [UnauthorizedError] on status code 401
  ///   - [UnauthorizedError] on status code 403
  ///   - [NotFoundError] on status code 404
  _i3.FutureOr<YankPackageResponse> yankPackageByNameAndVersion({
    required String name,
    required String version,
  });

  /// **Upload a package to the Pritt Server**
  /// POST /api/package/upload
  ///
  /// This API Endpoint is used to upload the tarball for the package
  /// Throws:
  ///   - [UnauthorizedError] on status code 401
  ///   - [UnauthorizedError] on status code 402
  ///   - [NotFoundError] on status code 404
  _i3.FutureOr<UploadPackageResponse> uploadPackageWithToken(
    BinaryContent body, {
    String id,
  });

  /// **List users from the Pritt Server**
  /// GET /api/users
  ///
  _i3.FutureOr<GetUsersResponse> getUsers();

  /// **Get a user from Pritt**
  /// GET /api/user/{id}
  ///
  /// Get user information from Pritt about a particular user given the user's id
  /// Throws:
  ///   - [NotFoundError] on status code 404
  _i3.FutureOr<GetUserResponse> getUserById({required String id});

  /// **Add a new user to Pritt**
  /// PUT /api/user/{id}
  ///
  _i3.FutureOr<AddUserResponse> addUserById(
    AddUserRequest body, {
    required String id,
  });

  /// **Get all custom adapters**
  /// GET /api/adapters
  ///
  /// Get an adapter with the given id
  _i3.FutureOr<GetAdaptersResponse> getAdapters();

  /// **Get an adapter with the given id**
  /// GET /api/adapter/{id}
  ///
  /// Get an adapter with the given id
  _i3.FutureOr<GetAdapterResponse> getAdapterById({required String id});

  /// **Create or update an adapter with the given id**
  /// POST /api/adapter/{id}
  ///
  /// Create or update an adapter with the given id
  _i3.FutureOr<dynamic> addAdapterWithId(
    dynamic body, {
    required String id,
  });

  /// **Yank an adapter with the given id**
  /// DELETE /api/adapter/{id}
  ///
  /// Yank an adapter with the given id
  _i3.FutureOr<dynamic> yankAdapterWithId({required String id});

  /// **Upload an adapter to the Pritt Server**
  /// POST /api/adapter/upload
  ///
  /// This API Endpoint is used to upload the tarball for the processed adapter
  _i3.FutureOr<UploadAdapterResponse> uploadAdapterWithToken(
    BinaryContent body, {
    String id,
  });

  /// **Get adapters by language**
  /// GET /api/adapter/{lang}
  ///
  /// Get the adapters for a particular language
  _i3.FutureOr<GetAdaptersByLangResponse> getAdaptersByLang();

  /// **Create token for a user**
  /// POST /api/auth/new
  ///
  /// Create a new token used for authenticating/creating a new user
  _i3.FutureOr<AuthResponse> createNewAuthStatus();

  /// **Validte Authentication Response**
  /// POST /api/auth/validate
  ///
  /// Validate or authenticate a user, creating a user if needed
  /// Throws:
  ///   - [ExpiredError] on status code 405
  _i3.FutureOr<AuthPollResponse> validateAuthStatus({String token});

  /// **Get Authentication Status**
  /// POST /api/auth/status
  ///
  /// Throws:
  ///   - [NotFoundError] on status code 404
  ///   - [ExpiredError] on status code 405
  _i3.FutureOr<AuthPollResponse> getAuthStatus();

  /// GET /api/archive/package/{name}
  ///
  _i3.FutureOr<dynamic> getPackageArchiveWithName();

  /// GET /api/archive/adapter/{id}
  ///
  _i3.FutureOr<dynamic> getAdapterArchiveWithName();
}

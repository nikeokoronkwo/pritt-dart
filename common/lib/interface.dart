// ignore_for_file: directives_ordering, non_constant_identifier_names

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i1;
import 'dart:convert' as _i2;
import 'package:json_annotation/json_annotation.dart' as _i3;
import 'dart:async' as _i4;
part 'interface.g.dart';

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

class StreamedContent extends Content {
  StreamedContent(this.data) : super([]);

  Stream<List<int>> data;

  @override
  List<int> get raw => throw Exception(
      'Do not call raw on streamed content: Use `data` instead');
}

@_i3.JsonSerializable()
class AddAdapterRequest {
  AddAdapterRequest();

  factory AddAdapterRequest.fromJson(Map<String, dynamic> json) =>
      _$AddAdapterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddAdapterRequestToJson(this);
}

@_i3.JsonSerializable()
class AddAdapterResponse {
  AddAdapterResponse();

  factory AddAdapterResponse.fromJson(Map<String, dynamic> json) =>
      _$AddAdapterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddAdapterResponseToJson(this);
}

@_i3.JsonSerializable()
class AddUserRequest {
  AddUserRequest();

  factory AddUserRequest.fromJson(Map<String, dynamic> json) =>
      _$AddUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddUserRequestToJson(this);
}

@_i3.JsonSerializable()
class AddUserResponse {
  AddUserResponse();

  factory AddUserResponse.fromJson(Map<String, dynamic> json) =>
      _$AddUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddUserResponseToJson(this);
}

@_i3.JsonSerializable()
class PollResponse {
  PollResponse();

  factory PollResponse.fromJson(Map<String, dynamic> json) =>
      _$PollResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PollResponseToJson(this);
}

@_i3.JsonSerializable()
class AuthPollResponse {
  AuthPollResponse({
    required this.status,
    this.response,
  });

  factory AuthPollResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthPollResponseFromJson(json);

  final String status;

  final PollResponse? response;

  Map<String, dynamic> toJson() => _$AuthPollResponseToJson(this);
}

@_i3.JsonSerializable()
class AuthResponse {
  AuthResponse({
    required this.token,
    required this.token_expires,
    required this.id,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  final String token;

  final int token_expires;

  final String id;

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@_i3.JsonSerializable()
class Error {
  Error({this.error});

  factory Error.fromJson(Map<String, dynamic> json) => _$ErrorFromJson(json);

  final String? error;

  Map<String, dynamic> toJson() => _$ErrorToJson(this);
}

@_i3.JsonSerializable()
class ExpiredError {
  ExpiredError({
    this.error,
    required this.expired_time,
  });

  factory ExpiredError.fromJson(Map<String, dynamic> json) =>
      _$ExpiredErrorFromJson(json);

  final String? error;

  final String expired_time;

  Map<String, dynamic> toJson() => _$ExpiredErrorToJson(this);
}

@_i3.JsonSerializable()
class GetAdapterResponse {
  GetAdapterResponse();

  factory GetAdapterResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAdapterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetAdapterResponseToJson(this);
}

@_i3.JsonSerializable()
class GetAdaptersByLangResponse {
  GetAdaptersByLangResponse();

  factory GetAdaptersByLangResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAdaptersByLangResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetAdaptersByLangResponseToJson(this);
}

@_i3.JsonSerializable()
class GetAdaptersResponse {
  GetAdaptersResponse();

  factory GetAdaptersResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAdaptersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetAdaptersResponseToJson(this);
}

@_i3.JsonSerializable()
class GetPackageByVersionResponse {
  GetPackageByVersionResponse();

  factory GetPackageByVersionResponse.fromJson(Map<String, dynamic> json) =>
      _$GetPackageByVersionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetPackageByVersionResponseToJson(this);
}

@_i3.JsonSerializable()
class Author {
  Author({
    required this.name,
    required this.email,
  });

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  final String name;

  final String email;

  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}

@_i3.JsonSerializable()
class Contributor {
  Contributor({
    required this.name,
    required this.email,
    this.role = const [],
  });

  factory Contributor.fromJson(Map<String, dynamic> json) =>
      _$ContributorFromJson(json);

  final String name;

  final String email;

  final List<String> role;

  Map<String, dynamic> toJson() => _$ContributorToJson(this);
}

@_i3.JsonSerializable()
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

  factory Package.fromJson(Map<String, dynamic> json) =>
      _$PackageFromJson(json);

  final String name;

  final String description;

  final String version;

  final Author author;

  final String? language;

  final String created_at;

  final String? updated_at;

  Map<String, dynamic> toJson() => _$PackageToJson(this);
}

@_i3.JsonSerializable()
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

  factory VerbosePackage.fromJson(Map<String, dynamic> json) =>
      _$VerbosePackageFromJson(json);

  final String name;

  final String description;

  final String version;

  final Author author;

  final String? language;

  final String created_at;

  final String? updated_at;

  final Map<String, Package> versions;

  final List<Author> authors;

  Map<String, dynamic> toJson() => _$VerbosePackageToJson(this);
}

@_i3.JsonSerializable()
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

  factory GetPackageResponse.fromJson(Map<String, dynamic> json) =>
      _$GetPackageResponseFromJson(json);

  final String name;

  final String latest_version;

  final Author author;

  final String? description;

  final List<Contributor> contributors;

  final String? language;

  final String created_at;

  final VerbosePackage latest;

  final Map<String, VerbosePackage> versions;

  Map<String, dynamic> toJson() => _$GetPackageResponseToJson(this);
}

@_i3.JsonSerializable()
class GetPackagesResponse {
  GetPackagesResponse({
    this.next_url,
    required this.packages,
  });

  factory GetPackagesResponse.fromJson(Map<String, dynamic> json) =>
      _$GetPackagesResponseFromJson(json);

  final String? next_url;

  final List<Package> packages;

  Map<String, dynamic> toJson() => _$GetPackagesResponseToJson(this);
}

@_i3.JsonSerializable()
class GetUserResponse {
  GetUserResponse();

  factory GetUserResponse.fromJson(Map<String, dynamic> json) =>
      _$GetUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetUserResponseToJson(this);
}

@_i3.JsonSerializable()
class GetUsersResponse {
  GetUsersResponse();

  factory GetUsersResponse.fromJson(Map<String, dynamic> json) =>
      _$GetUsersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetUsersResponseToJson(this);
}

@_i3.JsonSerializable()
class NotFoundError {
  NotFoundError({
    this.error,
    this.message,
  });

  factory NotFoundError.fromJson(Map<String, dynamic> json) =>
      _$NotFoundErrorFromJson(json);

  final String? error;

  final String? message;

  Map<String, dynamic> toJson() => _$NotFoundErrorToJson(this);
}

@_i3.JsonSerializable()
class PublishPackageByVersionRequest {
  PublishPackageByVersionRequest();

  factory PublishPackageByVersionRequest.fromJson(Map<String, dynamic> json) =>
      _$PublishPackageByVersionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PublishPackageByVersionRequestToJson(this);
}

@_i3.JsonSerializable()
class PublishPackageByVersionResponse {
  PublishPackageByVersionResponse();

  factory PublishPackageByVersionResponse.fromJson(Map<String, dynamic> json) =>
      _$PublishPackageByVersionResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PublishPackageByVersionResponseToJson(this);
}

@_i3.JsonSerializable()
class PublishPackageRequest {
  PublishPackageRequest({
    required this.name,
    required this.version,
    required this.config,
    required this.configFile,
  });

  factory PublishPackageRequest.fromJson(Map<String, dynamic> json) =>
      _$PublishPackageRequestFromJson(json);

  final String name;

  final String version;

  final Map<String, dynamic> config;

  final String configFile;

  Map<String, dynamic> toJson() => _$PublishPackageRequestToJson(this);
}

@_i3.JsonSerializable()
class PublishPackageResponse {
  PublishPackageResponse();

  factory PublishPackageResponse.fromJson(Map<String, dynamic> json) =>
      _$PublishPackageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PublishPackageResponseToJson(this);
}

@_i3.JsonSerializable()
class ServerError {
  ServerError({this.error});

  factory ServerError.fromJson(Map<String, dynamic> json) =>
      _$ServerErrorFromJson(json);

  final String? error;

  Map<String, dynamic> toJson() => _$ServerErrorToJson(this);
}

@_i3.JsonSerializable()
class UnauthorizedError {
  UnauthorizedError({this.error});

  factory UnauthorizedError.fromJson(Map<String, dynamic> json) =>
      _$UnauthorizedErrorFromJson(json);

  final String? error;

  Map<String, dynamic> toJson() => _$UnauthorizedErrorToJson(this);
}

@_i3.JsonSerializable()
class UploadAdapterResponse {
  UploadAdapterResponse();

  factory UploadAdapterResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadAdapterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadAdapterResponseToJson(this);
}

@_i3.JsonSerializable()
class UploadPackageResponse {
  UploadPackageResponse();

  factory UploadPackageResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadPackageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadPackageResponseToJson(this);
}

@_i3.JsonSerializable()
class YankAdapterResponse {
  YankAdapterResponse();

  factory YankAdapterResponse.fromJson(Map<String, dynamic> json) =>
      _$YankAdapterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$YankAdapterResponseToJson(this);
}

@_i3.JsonSerializable()
class YankPackageByVersionResponse {
  YankPackageByVersionResponse();

  factory YankPackageByVersionResponse.fromJson(Map<String, dynamic> json) =>
      _$YankPackageByVersionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$YankPackageByVersionResponseToJson(this);
}

@_i3.JsonSerializable()
class YankPackageRequest {
  YankPackageRequest({required this.version});

  factory YankPackageRequest.fromJson(Map<String, dynamic> json) =>
      _$YankPackageRequestFromJson(json);

  final String version;

  Map<String, dynamic> toJson() => _$YankPackageRequestToJson(this);
}

@_i3.JsonSerializable()
class YankPackageResponse {
  YankPackageResponse();

  factory YankPackageResponse.fromJson(Map<String, dynamic> json) =>
      _$YankPackageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$YankPackageResponseToJson(this);
}

/// The Pritt OpenAPI specification used for integrating Pritt with its internal tools (i.e generating schemas for endpoints on the Rust Server and Frontends (CLI and Web)),
/// as well as integrating with other tools.
abstract interface class PrittInterface {
  /// **Get all packages from the Pritt Server**
  /// GET /api/packages
  ///
  /// This GET Request retrieves metadata about all the packages in the registry. To get more information on a specific package use /api/package/{name}
  _i4.FutureOr<GetPackagesResponse> getPackages({String index});

  /// **Get a package from the Pritt Server with the given name**
  /// GET /api/package/{name}
  ///
  /// Throws:
  ///   - [NotFoundError] on status code 404
  _i4.FutureOr<GetPackageResponse> getPackageByName({
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
  _i4.FutureOr<PublishPackageResponse> publishPackage(
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
  _i4.FutureOr<YankPackageResponse> yankPackageByName(
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
  _i4.FutureOr<GetPackageByVersionResponse> getPackageByNameAndVersion({
    required String name,
    required String version,
  });

  /// **Publish a package to the Pritt Server with a specified version**
  /// POST /api/package/{name}/{version}
  ///
  /// This endpoint is used for publishing new versions of existing packages to Pritt, usually done via the Pritt CLI. Publishing is permanent and cannot be removed. To publish a new package, use the `/api/package/{name}` POST
  /// Throws:
  ///   - [UnauthorizedError] on status code 401
  _i4.FutureOr<PublishPackageByVersionResponse> publishPackageWithVersion(
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
  _i4.FutureOr<YankPackageResponse> yankPackageByNameAndVersion({
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
  _i4.FutureOr<UploadPackageResponse> uploadPackageWithToken(
    StreamedContent body, {
    String id,
  });

  /// **List users from the Pritt Server**
  /// GET /api/users
  ///
  _i4.FutureOr<GetUsersResponse> getUsers();

  /// **Get a user from Pritt**
  /// GET /api/user/{id}
  ///
  /// Get user information from Pritt about a particular user given the user's id
  /// Throws:
  ///   - [NotFoundError] on status code 404
  _i4.FutureOr<GetUserResponse> getUserById({required String id});

  /// **Add a new user to Pritt**
  /// PUT /api/user/{id}
  ///
  _i4.FutureOr<AddUserResponse> addUserById(
    AddUserRequest body, {
    required String id,
  });

  /// **Get all custom adapters**
  /// GET /api/adapters
  ///
  /// Get an adapter with the given id
  _i4.FutureOr<GetAdaptersResponse> getAdapters();

  /// **Get an adapter with the given id**
  /// GET /api/adapter/{id}
  ///
  /// Get an adapter with the given id
  _i4.FutureOr<GetAdapterResponse> getAdapterById({required String id});

  /// **Create or update an adapter with the given id**
  /// POST /api/adapter/{id}
  ///
  /// Create or update an adapter with the given id
  _i4.FutureOr<AddAdapterResponse> addAdapterWithId(
    AddAdapterRequest body, {
    required String id,
  });

  /// **Yank an adapter with the given id**
  /// DELETE /api/adapter/{id}
  ///
  /// Yank an adapter with the given id
  _i4.FutureOr<YankAdapterResponse> yankAdapterWithId({required String id});

  /// **Upload an adapter to the Pritt Server**
  /// POST /api/adapter/upload
  ///
  /// This API Endpoint is used to upload the tarball for the processed adapter
  _i4.FutureOr<UploadAdapterResponse> uploadAdapterWithToken(
    StreamedContent body, {
    String id,
  });

  /// **Get adapters by language**
  /// GET /api/adapter/{lang}
  ///
  /// Get the adapters for a particular language
  _i4.FutureOr<GetAdaptersByLangResponse> getAdaptersByLang();

  /// **Create token for a user**
  /// POST /api/auth/new
  ///
  /// Create a new token used for authenticating/creating a new user
  _i4.FutureOr<AuthResponse> createNewAuthStatus();

  /// **Validte Authentication Response**
  /// POST /api/auth/validate
  ///
  /// Validate or authenticate a user, creating a user if needed
  /// Throws:
  ///   - [ExpiredError] on status code 405
  _i4.FutureOr<AuthPollResponse> validateAuthStatus({String token});

  /// **Get Authentication Status**
  /// POST /api/auth/status
  ///
  /// Throws:
  ///   - [NotFoundError] on status code 404
  ///   - [ExpiredError] on status code 405
  _i4.FutureOr<AuthPollResponse> getAuthStatus();

  /// GET /api/archive/package/{name}
  ///
  _i4.FutureOr<StreamedContent> getPackageArchiveWithName();

  /// GET /api/archive/adapter/{id}
  ///
  _i4.FutureOr<StreamedContent> getAdapterArchiveWithName();
}

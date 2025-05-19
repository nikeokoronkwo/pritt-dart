// ignore_for_file: directives_ordering, non_constant_identifier_names

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i1;
import 'dart:convert' as _i2;
import 'dart:async' as _i3;
import 'package:json_annotation/json_annotation.dart';
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
  BinaryContent(
    this.name,
    this.data, {
    this.contentType = 'application/octet-stream',
  }) : super(data);

  _i1.Uint8List data;

  String name;

  String contentType;
}

class JSONContent extends Content {
  JSONContent(this.data) : super(_i2.jsonEncode(data).codeUnits);

  Map<String, dynamic> data;
}

class StreamedContent extends Content {
  StreamedContent(
    this.name,
    this.data, {
    this.contentType = 'application/octet-stream',
  }) : super([]);

  Stream<List<int>> data;

  String name;

  String contentType;

  @override
  List<int> get raw => throw Exception(
      'Do not call raw on streamed content: Use `data` instead');
}

@JsonSerializable()
class AddAdapterRequest {
  AddAdapterRequest();

  factory AddAdapterRequest.fromJson(Map<String, dynamic> json) =>
      _$AddAdapterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddAdapterRequestToJson(this);
}

@JsonSerializable()
class AddAdapterResponse {
  AddAdapterResponse();

  factory AddAdapterResponse.fromJson(Map<String, dynamic> json) =>
      _$AddAdapterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddAdapterResponseToJson(this);
}

@JsonSerializable()
class AddUserRequest {
  AddUserRequest();

  factory AddUserRequest.fromJson(Map<String, dynamic> json) =>
      _$AddUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddUserRequestToJson(this);
}

@JsonSerializable()
class AddUserResponse {
  AddUserResponse();

  factory AddUserResponse.fromJson(Map<String, dynamic> json) =>
      _$AddUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddUserResponseToJson(this);
}

@JsonEnum(valueField: 'value')
enum PollStatus {
  pending('pending'),
  success('success'),
  error('error');

  const PollStatus(this.value);

  final String value;
}

@JsonSerializable()
class PollResponse {
  PollResponse();

  factory PollResponse.fromJson(Map<String, dynamic> json) =>
      _$PollResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PollResponseToJson(this);
}

@JsonSerializable()
class AuthPollResponse {
  AuthPollResponse({
    required this.status,
    this.response,
  });

  factory AuthPollResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthPollResponseFromJson(json);

  final PollStatus status;

  final PollResponse? response;

  Map<String, dynamic> toJson() => _$AuthPollResponseToJson(this);
}

@JsonSerializable()
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

@JsonSerializable()
class Error {
  Error({this.error});

  factory Error.fromJson(Map<String, dynamic> json) => _$ErrorFromJson(json);

  final String? error;

  Map<String, dynamic> toJson() => _$ErrorToJson(this);
}

@JsonSerializable()
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

@JsonSerializable()
class GetAdapterResponse {
  GetAdapterResponse();

  factory GetAdapterResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAdapterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetAdapterResponseToJson(this);
}

@JsonSerializable()
class GetAdaptersByLangResponse {
  GetAdaptersByLangResponse();

  factory GetAdaptersByLangResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAdaptersByLangResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetAdaptersByLangResponseToJson(this);
}

@JsonSerializable()
class GetAdaptersResponse {
  GetAdaptersResponse();

  factory GetAdaptersResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAdaptersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetAdaptersResponseToJson(this);
}

@JsonSerializable()
class GetPackageByVersionResponse {
  GetPackageByVersionResponse();

  factory GetPackageByVersionResponse.fromJson(Map<String, dynamic> json) =>
      _$GetPackageByVersionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetPackageByVersionResponseToJson(this);
}

@JsonSerializable()
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

@JsonEnum(valueField: 'value')
enum Role {
  read('read'),
  write('write'),
  publish('publish'),
  ultimate('ultimate');

  const Role(this.value);

  final String value;
}

@JsonSerializable()
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

  final List<Role>? role;

  Map<String, dynamic> toJson() => _$ContributorToJson(this);
}

@JsonSerializable()
class Signature {
  Signature({
    required this.public_key_id,
    required this.signature,
    required this.created,
  });

  factory Signature.fromJson(Map<String, dynamic> json) =>
      _$SignatureFromJson(json);

  final String public_key_id;

  final String signature;

  final String created;

  Map<String, dynamic> toJson() => _$SignatureToJson(this);
}

@JsonSerializable()
class VerbosePackage {
  VerbosePackage({
    required this.name,
    this.description,
    required this.version,
    required this.author,
    this.language,
    required this.created_at,
    this.updated_at,
    required this.info,
    required this.env,
    required this.metadata,
    required this.signatures,
    this.deprecated,
    this.yanked,
  });

  factory VerbosePackage.fromJson(Map<String, dynamic> json) =>
      _$VerbosePackageFromJson(json);

  final String name;

  final String? description;

  final String version;

  final Author author;

  final String? language;

  final String created_at;

  final String? updated_at;

  final Map<String, dynamic> info;

  final Map<String, dynamic> env;

  final Map<String, dynamic> metadata;

  final List<Signature>? signatures;

  final bool? deprecated;

  final bool? yanked;

  Map<String, dynamic> toJson() => _$VerbosePackageToJson(this);
}

@JsonSerializable()
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

  final List<Contributor>? contributors;

  final String? language;

  final String created_at;

  final VerbosePackage latest;

  final Map<String, VerbosePackage> versions;

  Map<String, dynamic> toJson() => _$GetPackageResponseToJson(this);
}

@JsonSerializable()
class Package {
  Package({
    required this.name,
    this.description,
    required this.version,
    required this.author,
    this.language,
    required this.created_at,
    this.updated_at,
  });

  factory Package.fromJson(Map<String, dynamic> json) =>
      _$PackageFromJson(json);

  final String name;

  final String? description;

  final String version;

  final Author author;

  final String? language;

  final String created_at;

  final String? updated_at;

  Map<String, dynamic> toJson() => _$PackageToJson(this);
}

@JsonSerializable()
class GetPackagesResponse {
  GetPackagesResponse({
    this.next_url,
    required this.packages,
  });

  factory GetPackagesResponse.fromJson(Map<String, dynamic> json) =>
      _$GetPackagesResponseFromJson(json);

  final String? next_url;

  final List<Package>? packages;

  Map<String, dynamic> toJson() => _$GetPackagesResponseToJson(this);
}

@JsonSerializable()
class GetUserResponse {
  GetUserResponse();

  factory GetUserResponse.fromJson(Map<String, dynamic> json) =>
      _$GetUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetUserResponseToJson(this);
}

@JsonSerializable()
class GetUsersResponse {
  GetUsersResponse();

  factory GetUsersResponse.fromJson(Map<String, dynamic> json) =>
      _$GetUsersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetUsersResponseToJson(this);
}

@JsonSerializable()
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

@JsonSerializable()
class PublishPackageByVersionRequest {
  PublishPackageByVersionRequest();

  factory PublishPackageByVersionRequest.fromJson(Map<String, dynamic> json) =>
      _$PublishPackageByVersionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PublishPackageByVersionRequestToJson(this);
}

@JsonSerializable()
class PublishPackageByVersionResponse {
  PublishPackageByVersionResponse();

  factory PublishPackageByVersionResponse.fromJson(Map<String, dynamic> json) =>
      _$PublishPackageByVersionResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PublishPackageByVersionResponseToJson(this);
}

@JsonSerializable()
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

@JsonSerializable()
class PublishPackageResponse {
  PublishPackageResponse();

  factory PublishPackageResponse.fromJson(Map<String, dynamic> json) =>
      _$PublishPackageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PublishPackageResponseToJson(this);
}

@JsonSerializable()
class ServerError {
  ServerError({this.error});

  factory ServerError.fromJson(Map<String, dynamic> json) =>
      _$ServerErrorFromJson(json);

  final String? error;

  Map<String, dynamic> toJson() => _$ServerErrorToJson(this);
}

@JsonSerializable()
class UnauthorizedError {
  UnauthorizedError({this.error});

  factory UnauthorizedError.fromJson(Map<String, dynamic> json) =>
      _$UnauthorizedErrorFromJson(json);

  final String? error;

  Map<String, dynamic> toJson() => _$UnauthorizedErrorToJson(this);
}

@JsonSerializable()
class UploadAdapterResponse {
  UploadAdapterResponse();

  factory UploadAdapterResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadAdapterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadAdapterResponseToJson(this);
}

@JsonSerializable()
class UploadPackageResponse {
  UploadPackageResponse();

  factory UploadPackageResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadPackageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadPackageResponseToJson(this);
}

@JsonSerializable()
class YankAdapterResponse {
  YankAdapterResponse();

  factory YankAdapterResponse.fromJson(Map<String, dynamic> json) =>
      _$YankAdapterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$YankAdapterResponseToJson(this);
}

@JsonSerializable()
class YankPackageByVersionResponse {
  YankPackageByVersionResponse();

  factory YankPackageByVersionResponse.fromJson(Map<String, dynamic> json) =>
      _$YankPackageByVersionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$YankPackageByVersionResponseToJson(this);
}

@JsonSerializable()
class YankPackageRequest {
  YankPackageRequest({required this.version});

  factory YankPackageRequest.fromJson(Map<String, dynamic> json) =>
      _$YankPackageRequestFromJson(json);

  final String version;

  Map<String, dynamic> toJson() => _$YankPackageRequestToJson(this);
}

@JsonSerializable()
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
    PublishPackageRequest? body, {
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
    PublishPackageByVersionRequest? body, {
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
    StreamedContent body, {
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
    AddUserRequest? body, {
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
  _i3.FutureOr<AddAdapterResponse> addAdapterWithId(
    AddAdapterRequest? body, {
    required String id,
  });

  /// **Yank an adapter with the given id**
  /// DELETE /api/adapter/{id}
  ///
  /// Yank an adapter with the given id
  _i3.FutureOr<YankAdapterResponse> yankAdapterWithId({required String id});

  /// **Upload an adapter to the Pritt Server**
  /// POST /api/adapter/upload
  ///
  /// This API Endpoint is used to upload the tarball for the processed adapter
  _i3.FutureOr<UploadAdapterResponse> uploadAdapterWithToken(
    StreamedContent body, {
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
  _i3.FutureOr<StreamedContent> getPackageArchiveWithName();

  /// GET /api/archive/adapter/{id}
  ///
  _i3.FutureOr<StreamedContent> getAdapterArchiveWithName();
}

library pritt.common;

export 'src/schemas.dart';
export 'src/errors.dart';
export 'src/content.dart';
export 'src/utils/result.dart';

import 'dart:async';

import 'src/content.dart';
import 'src/errors.dart';
import 'src/utils/result.dart';
import 'src/schemas.dart';

/// The Pritt OpenAPI specification used for integrating Pritt with its internal tools (i.e generating schemas for endpoints on the Rust Server and Frontends (CLI and Web)),
/// as well as integrating with other tools.
abstract interface class PrittInterface {
  /// Get all packages from the Pritt Server
  /// 
  /// GET `/api/packages`
  FutureOr<GetPackagesResponse> getPackages();

  /// Get a package from the Pritt Server with the given name
  /// 
  /// GET `/api/package/{name}`
  FutureOr<Result<GetPackageResponse, NotFoundError>> getPackageByName({required String name});

  /// Publish a package to the Pritt Server
  /// 
  /// POST `/api/package/{name}`
  FutureOr<Result<PublishPackageResponse, UnauthorizedError>> publishPackage(
      PublishPackageRequest body,
      {required String name});

  /// Yank (an empty) package
  /// 
  /// DELETE `/api/package/{name}`
  FutureOr<Result<YankPackageResponse, RequestError>> yankPackageByName(YankPackageRequest? body, {required String name});

  /// Get a package from the Pritt Server with the given name and specified version
  /// 
  /// GET `/api/package/{name}/{version}`
  FutureOr<Result<GetPackageByVersionResponse, NotFoundError>> getPackageByNameAndVersion(
      {required String name, required String version});

  /// Publish a package to the Pritt Server with a specified version
  /// 
  /// POST `/api/package/{name}/{version}`
  FutureOr<Result<PublishPackageByVersionResponse, UnauthorizedError>>
      publishPackageWithVersion(PublishPackageByVersionRequest body,
          {required String name, required String version});

  /// Yank a version of a package to the Pritt Server with a specified version
  /// 
  /// DELETE `/api/package/{name}/{version}`
  FutureOr<Result<YankPackageByVersionResponse, UnauthorizedError>>
      yankPackageByNameAndVersion(PublishPackageByVersionRequest body,
          {required String name, required String version});

  /// 'Upload a package to the Pritt Server: This API Endpoint is called after a subsequent call to /api/package/{name}(/{version})'
  /// 
  /// POST `/api/package/upload`
  FutureOr<Result<UploadPackageResponse, RequestError>> uploadPackageWithToken(GZipContent body, {required String id});

  /// List users from the Pritt Server
  /// 
  /// GET `/api/users`
  FutureOr<GetUsersResponse> getUsers();

  /// Get a user from Pritt
  /// 
  /// GET `/api/user/{id}`
  FutureOr<Result<GetUserResponse, NotFoundError>> getUserById({required String id});

  /// Add a new user to Pritt
  /// 
  /// POST `/api/user/{id}`
  FutureOr<Result<AddUserResponse, ServerError>> addUserById(AddUserRequest body, {required String id});

  /// Get adapters
  /// 
  /// GET `/api/adapters`
  FutureOr<GetAdaptersResponse> getAdapters();

  /// Get an adapter with the given id
  /// 
  /// GET `/api/adapter/{id}`
  FutureOr<Result<GetAdaptersResponse, RequestError>> getAdapterById({required String id});

  /// Create or update an adapter with the given id
  /// 
  /// POST `/api/adapter/{id}`
  FutureOr<Result<GetAdaptersResponse, RequestError>> addAdapterWithId(AddAdapterRequest body, {required String id});

  /// Yank an adapter with the given id
  /// 
  /// DELETE `/api/adapter/{id}`
  FutureOr<Result<YankAdapterResponse, RequestError>> yankAdapterWithId({required String id});
}

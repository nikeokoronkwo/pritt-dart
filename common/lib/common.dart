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
  FutureOr<GetPackagesResponse> getPackages();

  /// Get a package from the Pritt Server with the given name
  FutureOr<GetPackageResponse> getPackageByName({required String name});

  /// Publish a package to the Pritt Server
  FutureOr<Result<PublishPackageResponse, UnauthorizedError>> publishPackage(
      PublishPackageRequest body,
      {required String name});

  /// Get a package from the Pritt Server with the given name and specified version
  FutureOr<GetPackageByVersionResponse> getPackageByNameAndVersion(
      {required String name, required String version});

  /// Publish a package to the Pritt Server with a specified version
  FutureOr<Result<PublishPackageByVersionResponse, UnauthorizedError>>
      publishPackageWithVersion(PublishPackageByVersionRequest body,
          {required String name, required String version});

  /// 'Upload a package to the Pritt Server: This API Endpoint is called after a subsequent call to /api/package/{name}(/{version})'
  FutureOr<Result<UploadPackageResponse, UnauthorizedError>> uploadPackageWithToken(GZipContent body, {required String id});

  /// List users from the Pritt Server
  FutureOr<GetUsersResponse> getUsers();

  /// Get a user from Pritt
  FutureOr<Result<GetUserResponse, NotFoundError>> getUserById({required String id});

  /// Add a new user to Pritt
  FutureOr<Result<AddUserResponse, ServerError>> addUserById(AddUserRequest body, {required String id});
}

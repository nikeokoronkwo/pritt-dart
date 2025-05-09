

import 'dart:async';

import 'package:pritt_cli/src/client/base.dart';
import 'package:pritt_common/common.dart';

class PrittClient extends ApiClient implements PrittInterface {
  PrittClient({super.url});

  @override
  FutureOr<Result<AddUserResponse, ServerError>> addUserById(AddUserRequest body, {required String id}) {
    // TODO: implement addUserById
    throw UnimplementedError();
  }

  @override
  FutureOr<GetPackageResponse> getPackageByName({required String name}) {
    // TODO: implement getPackageByName
    throw UnimplementedError();
  }

  @override
  FutureOr<GetPackageByVersionResponse> getPackageByNameAndVersion({required String name, required String version}) {
    // TODO: implement getPackageByNameAndVersion
    throw UnimplementedError();
  }

  @override
  FutureOr<GetPackagesResponse> getPackages() {
    // TODO: implement getPackages
    throw UnimplementedError();
  }

  @override
  FutureOr<Result<GetUserResponse, NotFoundError>> getUserById({required String id}) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  FutureOr<GetUsersResponse> getUsers() {
    // TODO: implement getUsers
    throw UnimplementedError();
  }

  @override
  FutureOr<Result<PublishPackageResponse, UnauthorizedError>> publishPackage(PublishPackageRequest body, {required String name}) {
    // TODO: implement publishPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<Result<PublishPackageByVersionResponse, UnauthorizedError>> publishPackageWithVersion(PublishPackageByVersionRequest body, {required String name, required String version}) {
    // TODO: implement publishPackageWithVersion
    throw UnimplementedError();
  }

  @override
  FutureOr<Result<UploadPackageResponse, UnauthorizedError>> uploadPackageWithToken(GZipContent body, {required String id}) {
    // TODO: implement uploadPackageWithToken
    throw UnimplementedError();
  }
  
}
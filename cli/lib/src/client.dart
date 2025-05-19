import 'dart:async';

import 'package:pritt_cli/src/client/base.dart';
import 'package:pritt_cli/src/constants.dart';
import 'package:pritt_common/interface.dart';

class PrittClient extends ApiClient implements PrittInterface {
  PrittClient({super.url});

  @override
  FutureOr addAdapterWithId(body) {
    // TODO: implement addAdapterWithId
    throw UnimplementedError();
  }

  @override
  FutureOr<AddUserResponse> addUserById(AddUserRequest body) {
    // TODO: implement addUserById
    throw UnimplementedError();
  }

  @override
  FutureOr<AuthResponse> createNewAuthStatus() {
    // TODO: implement createNewAuthStatus
    throw UnimplementedError();
  }

  @override
  FutureOr getAdapterArchiveWithName() {
    // TODO: implement getAdapterArchiveWithName
    throw UnimplementedError();
  }

  @override
  FutureOr getAdapterById() {
    // TODO: implement getAdapterById
    throw UnimplementedError();
  }

  @override
  FutureOr<GetAdaptersResponse> getAdapters() {
    // TODO: implement getAdapters
    throw UnimplementedError();
  }

  @override
  FutureOr getAdaptersByLang() {
    // TODO: implement getAdaptersByLang
    throw UnimplementedError();
  }

  @override
  FutureOr<AuthPollResponse> getAuthStatus() {
    // TODO: implement getAuthStatus
    throw UnimplementedError();
  }

  @override
  FutureOr getPackageArchiveWithName() {
    // TODO: implement getPackageArchiveWithName
    throw UnimplementedError();
  }

  @override
  FutureOr<GetPackageResponse> getPackageByName() {
    // TODO: implement getPackageByName
    throw UnimplementedError();
  }

  @override
  FutureOr<GetPackageByVersionResponse> getPackageByNameAndVersion() {
    // TODO: implement getPackageByNameAndVersion
    throw UnimplementedError();
  }

  @override
  FutureOr<GetPackagesResponse> getPackages() {
    // TODO: implement getPackages
    throw UnimplementedError();
  }

  @override
  FutureOr<GetUserResponse> getUserById() {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  FutureOr<GetUsersResponse> getUsers() {
    // TODO: implement getUsers
    throw UnimplementedError();
  }

  @override
  FutureOr<PublishPackageResponse> publishPackage(PublishPackageRequest body) {
    // TODO: implement publishPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<PublishPackageByVersionResponse> publishPackageWithVersion(
      PublishPackageByVersionRequest body) {
    // TODO: implement publishPackageWithVersion
    throw UnimplementedError();
  }

  @override
  FutureOr uploadAdapterWithToken(body) {
    // TODO: implement uploadAdapterWithToken
    throw UnimplementedError();
  }

  @override
  FutureOr<UploadPackageResponse> uploadPackageWithToken(body) {
    // TODO: implement uploadPackageWithToken
    throw UnimplementedError();
  }

  @override
  FutureOr<AuthPollResponse> validateAuthStatus() {
    // TODO: implement validateAuthStatus
    throw UnimplementedError();
  }

  @override
  FutureOr yankAdapterWithId() {
    // TODO: implement yankAdapterWithId
    throw UnimplementedError();
  }

  @override
  FutureOr<YankPackageResponse> yankPackageByName(YankPackageRequest body) {
    // TODO: implement yankPackageByName
    throw UnimplementedError();
  }

  @override
  FutureOr<YankPackageResponse> yankPackageByNameAndVersion() {
    // TODO: implement yankPackageByNameAndVersion
    throw UnimplementedError();
  }
}

/// A single root client that connects to the main pritt url
final rootClient = PrittClient(url: mainPrittInstance);

import 'dart:async';

import 'package:pritt_cli/src/client/base.dart';
import 'package:pritt_cli/src/constants.dart';
import 'package:pritt_common/interface.dart';

class PrittClient extends ApiClient implements PrittInterface {
  PrittClient({super.url});
  
  @override
  FutureOr<AddAdapterResponse> addAdapterWithId(AddAdapterRequest body, {required String id}) {
    // TODO: implement addAdapterWithId
    throw UnimplementedError();
  }
  
  @override
  FutureOr<AddUserResponse> addUserById(AddUserRequest body, {required String id}) {
    // TODO: implement addUserById
    throw UnimplementedError();
  }
  
  @override
  FutureOr<AuthResponse> createNewAuthStatus() {
    // TODO: implement createNewAuthStatus
    throw UnimplementedError();
  }
  
  @override
  FutureOr<StreamedContent> getAdapterArchiveWithName() {
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
  FutureOr<AuthPollResponse> getAuthStatus() {
    // TODO: implement getAuthStatus
    throw UnimplementedError();
  }
  
  @override
  FutureOr<StreamedContent> getPackageArchiveWithName() {
    // TODO: implement getPackageArchiveWithName
    throw UnimplementedError();
  }
  
  @override
  FutureOr<GetPackageResponse> getPackageByName({required String name, String? lang, bool? all}) {
    // TODO: implement getPackageByName
    throw UnimplementedError();
  }
  
  @override
  FutureOr<GetPackageByVersionResponse> getPackageByNameAndVersion({required String name, required String version}) {
    // TODO: implement getPackageByNameAndVersion
    throw UnimplementedError();
  }
  
  @override
  FutureOr<GetPackagesResponse> getPackages({String? index}) {
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
  FutureOr<PublishPackageResponse> publishPackage(PublishPackageRequest body, {required String name, String? lang, bool? all}) {
    // TODO: implement publishPackage
    throw UnimplementedError();
  }
  
  @override
  FutureOr<PublishPackageByVersionResponse> publishPackageWithVersion(PublishPackageByVersionRequest body, {required String name, required String version}) {
    // TODO: implement publishPackageWithVersion
    throw UnimplementedError();
  }
  
  @override
  FutureOr<UploadAdapterResponse> uploadAdapterWithToken(StreamedContent body, {String? id}) {
    // TODO: implement uploadAdapterWithToken
    throw UnimplementedError();
  }
  
  @override
  FutureOr<UploadPackageResponse> uploadPackageWithToken(StreamedContent body, {String? id}) {
    // TODO: implement uploadPackageWithToken
    throw UnimplementedError();
  }
  
  @override
  FutureOr<AuthPollResponse> validateAuthStatus({String? token}) {
    // TODO: implement validateAuthStatus
    throw UnimplementedError();
  }
  
  @override
  FutureOr<YankAdapterResponse> yankAdapterWithId({required String id}) {
    // TODO: implement yankAdapterWithId
    throw UnimplementedError();
  }
  
  @override
  FutureOr<YankPackageResponse> yankPackageByName(YankPackageRequest body, {required String name, String? lang, bool? all}) {
    // TODO: implement yankPackageByName
    throw UnimplementedError();
  }
  
  @override
  FutureOr<YankPackageResponse> yankPackageByNameAndVersion({required String name, required String version}) {
    // TODO: implement yankPackageByNameAndVersion
    throw UnimplementedError();
  }

  
}

/// A single root client that connects to the main pritt url
final rootClient = PrittClient(url: mainPrittInstance);

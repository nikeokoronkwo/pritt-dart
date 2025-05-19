// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interface.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddAdapterRequest _$AddAdapterRequestFromJson(Map<String, dynamic> json) =>
    AddAdapterRequest();

Map<String, dynamic> _$AddAdapterRequestToJson(AddAdapterRequest instance) =>
    <String, dynamic>{};

AddAdapterResponse _$AddAdapterResponseFromJson(Map<String, dynamic> json) =>
    AddAdapterResponse();

Map<String, dynamic> _$AddAdapterResponseToJson(AddAdapterResponse instance) =>
    <String, dynamic>{};

AddUserRequest _$AddUserRequestFromJson(Map<String, dynamic> json) =>
    AddUserRequest();

Map<String, dynamic> _$AddUserRequestToJson(AddUserRequest instance) =>
    <String, dynamic>{};

AddUserResponse _$AddUserResponseFromJson(Map<String, dynamic> json) =>
    AddUserResponse();

Map<String, dynamic> _$AddUserResponseToJson(AddUserResponse instance) =>
    <String, dynamic>{};

PollResponse _$PollResponseFromJson(Map<String, dynamic> json) =>
    PollResponse();

Map<String, dynamic> _$PollResponseToJson(PollResponse instance) =>
    <String, dynamic>{};

AuthPollResponse _$AuthPollResponseFromJson(Map<String, dynamic> json) =>
    AuthPollResponse(
      status: json['status'] as String,
      response: json['response'] == null
          ? null
          : PollResponse.fromJson(json['response'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthPollResponseToJson(AuthPollResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'response': instance.response,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      token: json['token'] as String,
      token_expires: (json['token_expires'] as num).toInt(),
      id: json['id'] as String,
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'token_expires': instance.token_expires,
      'id': instance.id,
    };

Error _$ErrorFromJson(Map<String, dynamic> json) => Error(
      error: json['error'] as String?,
    );

Map<String, dynamic> _$ErrorToJson(Error instance) => <String, dynamic>{
      'error': instance.error,
    };

ExpiredError _$ExpiredErrorFromJson(Map<String, dynamic> json) => ExpiredError(
      error: json['error'] as String?,
      expired_time: json['expired_time'] as String,
    );

Map<String, dynamic> _$ExpiredErrorToJson(ExpiredError instance) =>
    <String, dynamic>{
      'error': instance.error,
      'expired_time': instance.expired_time,
    };

GetAdapterResponse _$GetAdapterResponseFromJson(Map<String, dynamic> json) =>
    GetAdapterResponse();

Map<String, dynamic> _$GetAdapterResponseToJson(GetAdapterResponse instance) =>
    <String, dynamic>{};

GetAdaptersByLangResponse _$GetAdaptersByLangResponseFromJson(
        Map<String, dynamic> json) =>
    GetAdaptersByLangResponse();

Map<String, dynamic> _$GetAdaptersByLangResponseToJson(
        GetAdaptersByLangResponse instance) =>
    <String, dynamic>{};

GetAdaptersResponse _$GetAdaptersResponseFromJson(Map<String, dynamic> json) =>
    GetAdaptersResponse();

Map<String, dynamic> _$GetAdaptersResponseToJson(
        GetAdaptersResponse instance) =>
    <String, dynamic>{};

GetPackageByVersionResponse _$GetPackageByVersionResponseFromJson(
        Map<String, dynamic> json) =>
    GetPackageByVersionResponse();

Map<String, dynamic> _$GetPackageByVersionResponseToJson(
        GetPackageByVersionResponse instance) =>
    <String, dynamic>{};

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
      name: json['name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
    };

Contributor _$ContributorFromJson(Map<String, dynamic> json) => Contributor(
      name: json['name'] as String,
      email: json['email'] as String,
      role:
          (json['role'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$ContributorToJson(Contributor instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
    };

Package _$PackageFromJson(Map<String, dynamic> json) => Package(
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      language: json['language'] as String?,
      created_at: json['created_at'] as String,
      updated_at: json['updated_at'] as String?,
    );

Map<String, dynamic> _$PackageToJson(Package instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'version': instance.version,
      'author': instance.author,
      'language': instance.language,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
    };

VerbosePackage _$VerbosePackageFromJson(Map<String, dynamic> json) =>
    VerbosePackage(
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      language: json['language'] as String?,
      created_at: json['created_at'] as String,
      updated_at: json['updated_at'] as String?,
      versions: (json['versions'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Package.fromJson(e as Map<String, dynamic>)),
      ),
      authors: (json['authors'] as List<dynamic>)
          .map((e) => Author.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VerbosePackageToJson(VerbosePackage instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'version': instance.version,
      'author': instance.author,
      'language': instance.language,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
      'versions': instance.versions,
      'authors': instance.authors,
    };

GetPackageResponse _$GetPackageResponseFromJson(Map<String, dynamic> json) =>
    GetPackageResponse(
      name: json['name'] as String,
      latest_version: json['latest_version'] as String,
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      description: json['description'] as String?,
      contributors: (json['contributors'] as List<dynamic>)
          .map((e) => Contributor.fromJson(e as Map<String, dynamic>))
          .toList(),
      language: json['language'] as String?,
      created_at: json['created_at'] as String,
      latest: VerbosePackage.fromJson(json['latest'] as Map<String, dynamic>),
      versions: (json['versions'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, VerbosePackage.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$GetPackageResponseToJson(GetPackageResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'latest_version': instance.latest_version,
      'author': instance.author,
      'description': instance.description,
      'contributors': instance.contributors,
      'language': instance.language,
      'created_at': instance.created_at,
      'latest': instance.latest,
      'versions': instance.versions,
    };

GetPackagesResponse _$GetPackagesResponseFromJson(Map<String, dynamic> json) =>
    GetPackagesResponse(
      next_url: json['next_url'] as String?,
      packages: (json['packages'] as List<dynamic>)
          .map((e) => Package.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetPackagesResponseToJson(
        GetPackagesResponse instance) =>
    <String, dynamic>{
      'next_url': instance.next_url,
      'packages': instance.packages,
    };

GetUserResponse _$GetUserResponseFromJson(Map<String, dynamic> json) =>
    GetUserResponse();

Map<String, dynamic> _$GetUserResponseToJson(GetUserResponse instance) =>
    <String, dynamic>{};

GetUsersResponse _$GetUsersResponseFromJson(Map<String, dynamic> json) =>
    GetUsersResponse();

Map<String, dynamic> _$GetUsersResponseToJson(GetUsersResponse instance) =>
    <String, dynamic>{};

NotFoundError _$NotFoundErrorFromJson(Map<String, dynamic> json) =>
    NotFoundError(
      error: json['error'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$NotFoundErrorToJson(NotFoundError instance) =>
    <String, dynamic>{
      'error': instance.error,
      'message': instance.message,
    };

PublishPackageByVersionRequest _$PublishPackageByVersionRequestFromJson(
        Map<String, dynamic> json) =>
    PublishPackageByVersionRequest();

Map<String, dynamic> _$PublishPackageByVersionRequestToJson(
        PublishPackageByVersionRequest instance) =>
    <String, dynamic>{};

PublishPackageByVersionResponse _$PublishPackageByVersionResponseFromJson(
        Map<String, dynamic> json) =>
    PublishPackageByVersionResponse();

Map<String, dynamic> _$PublishPackageByVersionResponseToJson(
        PublishPackageByVersionResponse instance) =>
    <String, dynamic>{};

PublishPackageRequest _$PublishPackageRequestFromJson(
        Map<String, dynamic> json) =>
    PublishPackageRequest(
      name: json['name'] as String,
      version: json['version'] as String,
      config: json['config'] as Map<String, dynamic>,
      configFile: json['configFile'] as String,
    );

Map<String, dynamic> _$PublishPackageRequestToJson(
        PublishPackageRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'config': instance.config,
      'configFile': instance.configFile,
    };

PublishPackageResponse _$PublishPackageResponseFromJson(
        Map<String, dynamic> json) =>
    PublishPackageResponse();

Map<String, dynamic> _$PublishPackageResponseToJson(
        PublishPackageResponse instance) =>
    <String, dynamic>{};

ServerError _$ServerErrorFromJson(Map<String, dynamic> json) => ServerError(
      error: json['error'] as String?,
    );

Map<String, dynamic> _$ServerErrorToJson(ServerError instance) =>
    <String, dynamic>{
      'error': instance.error,
    };

UnauthorizedError _$UnauthorizedErrorFromJson(Map<String, dynamic> json) =>
    UnauthorizedError(
      error: json['error'] as String?,
    );

Map<String, dynamic> _$UnauthorizedErrorToJson(UnauthorizedError instance) =>
    <String, dynamic>{
      'error': instance.error,
    };

UploadAdapterResponse _$UploadAdapterResponseFromJson(
        Map<String, dynamic> json) =>
    UploadAdapterResponse();

Map<String, dynamic> _$UploadAdapterResponseToJson(
        UploadAdapterResponse instance) =>
    <String, dynamic>{};

UploadPackageResponse _$UploadPackageResponseFromJson(
        Map<String, dynamic> json) =>
    UploadPackageResponse();

Map<String, dynamic> _$UploadPackageResponseToJson(
        UploadPackageResponse instance) =>
    <String, dynamic>{};

YankAdapterResponse _$YankAdapterResponseFromJson(Map<String, dynamic> json) =>
    YankAdapterResponse();

Map<String, dynamic> _$YankAdapterResponseToJson(
        YankAdapterResponse instance) =>
    <String, dynamic>{};

YankPackageByVersionResponse _$YankPackageByVersionResponseFromJson(
        Map<String, dynamic> json) =>
    YankPackageByVersionResponse();

Map<String, dynamic> _$YankPackageByVersionResponseToJson(
        YankPackageByVersionResponse instance) =>
    <String, dynamic>{};

YankPackageRequest _$YankPackageRequestFromJson(Map<String, dynamic> json) =>
    YankPackageRequest(
      version: json['version'] as String,
    );

Map<String, dynamic> _$YankPackageRequestToJson(YankPackageRequest instance) =>
    <String, dynamic>{
      'version': instance.version,
    };

YankPackageResponse _$YankPackageResponseFromJson(Map<String, dynamic> json) =>
    YankPackageResponse();

Map<String, dynamic> _$YankPackageResponseToJson(
        YankPackageResponse instance) =>
    <String, dynamic>{};

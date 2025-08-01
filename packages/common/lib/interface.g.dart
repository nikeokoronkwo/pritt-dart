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

AuthDetailsResponse _$AuthDetailsResponseFromJson(Map<String, dynamic> json) =>
    AuthDetailsResponse(
      token: json['token'] as String,
      token_expires: json['token_expires'] as String,
      device: json['device'] as String,
      code: json['code'] as String,
      status: $enumDecode(_$PollStatusEnumMap, json['status']),
      user_id: json['user_id'] as String?,
    );

Map<String, dynamic> _$AuthDetailsResponseToJson(
  AuthDetailsResponse instance,
) => <String, dynamic>{
  'token': instance.token,
  'token_expires': instance.token_expires,
  'device': instance.device,
  'code': instance.code,
  'status': _$PollStatusEnumMap[instance.status]!,
  'user_id': ?instance.user_id,
};

const _$PollStatusEnumMap = {
  PollStatus.success: 'success',
  PollStatus.fail: 'fail',
  PollStatus.error: 'error',
  PollStatus.expired: 'expired',
  PollStatus.pending: 'pending',
};

AuthError _$AuthErrorFromJson(Map<String, dynamic> json) => AuthError(
  error: json['error'] as String?,
  status: $enumDecode(_$PollStatusEnumMap, json['status']),
);

Map<String, dynamic> _$AuthErrorToJson(AuthError instance) => <String, dynamic>{
  'error': ?instance.error,
  'status': _$PollStatusEnumMap[instance.status]!,
};

AuthPollResponse _$AuthPollResponseFromJson(Map<String, dynamic> json) =>
    AuthPollResponse(
      status: $enumDecode(_$PollStatusEnumMap, json['status']),
      response: json['response'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AuthPollResponseToJson(AuthPollResponse instance) =>
    <String, dynamic>{
      'status': _$PollStatusEnumMap[instance.status]!,
      'response': ?instance.response,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  token: json['token'] as String,
  token_expires: json['token_expires'] as String,
  device: json['device'] as String,
  code: json['code'] as String,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'token_expires': instance.token_expires,
      'device': instance.device,
      'code': instance.code,
    };

AuthValidateRequest _$AuthValidateRequestFromJson(Map<String, dynamic> json) =>
    AuthValidateRequest(
      user_id: json['user_id'] as String,
      session_id: json['session_id'] as String,
      time: json['time'] as String,
      status: $enumDecode(_$ValidatedPollStatusEnumMap, json['status']),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$AuthValidateRequestToJson(
  AuthValidateRequest instance,
) => <String, dynamic>{
  'user_id': instance.user_id,
  'session_id': instance.session_id,
  'time': instance.time,
  'status': _$ValidatedPollStatusEnumMap[instance.status]!,
  'error': ?instance.error,
};

const _$ValidatedPollStatusEnumMap = {
  ValidatedPollStatus.success: 'success',
  ValidatedPollStatus.fail: 'fail',
  ValidatedPollStatus.error: 'error',
};

AuthValidateResponse _$AuthValidateResponseFromJson(
  Map<String, dynamic> json,
) => AuthValidateResponse(validated: json['validated'] as bool);

Map<String, dynamic> _$AuthValidateResponseToJson(
  AuthValidateResponse instance,
) => <String, dynamic>{'validated': instance.validated};

Error _$ErrorFromJson(Map<String, dynamic> json) =>
    Error(error: json['error'] as String?);

Map<String, dynamic> _$ErrorToJson(Error instance) => <String, dynamic>{
  'error': ?instance.error,
};

ExistsError _$ExistsErrorFromJson(Map<String, dynamic> json) =>
    ExistsError(error: json['error'] as String?, name: json['name'] as String);

Map<String, dynamic> _$ExistsErrorToJson(ExistsError instance) =>
    <String, dynamic>{'error': ?instance.error, 'name': instance.name};

ExpiredError _$ExpiredErrorFromJson(Map<String, dynamic> json) => ExpiredError(
  error: json['error'] as String?,
  expired_time: json['expired_time'] as String,
);

Map<String, dynamic> _$ExpiredErrorToJson(ExpiredError instance) =>
    <String, dynamic>{
      'error': ?instance.error,
      'expired_time': instance.expired_time,
    };

GetAdapterResponse _$GetAdapterResponseFromJson(Map<String, dynamic> json) =>
    GetAdapterResponse(
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String?,
      language: json['language'] as String?,
      uploaded_at: json['uploaded_at'] as String,
      source_url: json['source_url'] as String?,
    );

Map<String, dynamic> _$GetAdapterResponseToJson(GetAdapterResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'description': ?instance.description,
      'language': ?instance.language,
      'uploaded_at': instance.uploaded_at,
      'source_url': ?instance.source_url,
    };

GetAdaptersByLangResponse _$GetAdaptersByLangResponseFromJson(
  Map<String, dynamic> json,
) => GetAdaptersByLangResponse();

Map<String, dynamic> _$GetAdaptersByLangResponseToJson(
  GetAdaptersByLangResponse instance,
) => <String, dynamic>{};

Plugin _$PluginFromJson(Map<String, dynamic> json) => Plugin(
  name: json['name'] as String,
  version: json['version'] as String,
  description: json['description'] as String?,
  language: json['language'] as String?,
  uploaded_at: json['uploaded_at'] as String,
  source_url: json['source_url'] as String?,
);

Map<String, dynamic> _$PluginToJson(Plugin instance) => <String, dynamic>{
  'name': instance.name,
  'version': instance.version,
  'description': ?instance.description,
  'language': ?instance.language,
  'uploaded_at': instance.uploaded_at,
  'source_url': ?instance.source_url,
};

GetAdaptersResponse _$GetAdaptersResponseFromJson(Map<String, dynamic> json) =>
    GetAdaptersResponse(
      adapters: (json['adapters'] as List<dynamic>?)
          ?.map((e) => Plugin.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetAdaptersResponseToJson(
  GetAdaptersResponse instance,
) => <String, dynamic>{'adapters': ?instance.adapters};

PackageMap _$PackageMapFromJson(Map<String, dynamic> json) => PackageMap(
  name: json['name'] as String,
  type: $enumDecode(_$UserPackageRelationshipEnumMap, json['type']),
  privileges:
      (json['privileges'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$PrivilegeEnumMap, e))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PackageMapToJson(PackageMap instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$UserPackageRelationshipEnumMap[instance.type]!,
      'privileges': ?instance.privileges
          ?.map((e) => _$PrivilegeEnumMap[e]!)
          .toList(),
    };

const _$UserPackageRelationshipEnumMap = {
  UserPackageRelationship.author: 'author',
  UserPackageRelationship.contributor: 'contributor',
};

const _$PrivilegeEnumMap = {
  Privilege.read: 'read',
  Privilege.write: 'write',
  Privilege.publish: 'publish',
  Privilege.ultimate: 'ultimate',
};

GetCurrentUserResponse _$GetCurrentUserResponseFromJson(
  Map<String, dynamic> json,
) => GetCurrentUserResponse(
  name: json['name'] as String,
  email: json['email'] as String,
  created_at: json['created_at'] as String,
  updated_at: json['updated_at'] as String,
  packages: (json['packages'] as List<dynamic>?)
      ?.map((e) => PackageMap.fromJson(e as Map<String, dynamic>))
      .toList(),
  id: json['id'] as String,
);

Map<String, dynamic> _$GetCurrentUserResponseToJson(
  GetCurrentUserResponse instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'created_at': instance.created_at,
  'updated_at': instance.updated_at,
  'packages': ?instance.packages,
  'id': instance.id,
};

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
  name: json['name'] as String,
  email: json['email'] as String,
  avatar: json['avatar'] as String?,
);

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'avatar': ?instance.avatar,
};

Contributor _$ContributorFromJson(Map<String, dynamic> json) => Contributor(
  name: json['name'] as String,
  email: json['email'] as String,
  avatar: json['avatar'] as String?,
  privileges:
      (json['privileges'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$PrivilegeEnumMap, e))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ContributorToJson(Contributor instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'avatar': ?instance.avatar,
      'privileges': ?instance.privileges
          ?.map((e) => _$PrivilegeEnumMap[e]!)
          .toList(),
    };

Signature _$SignatureFromJson(Map<String, dynamic> json) => Signature(
  public_key_id: json['public_key_id'] as String,
  signature: json['signature'] as String,
  created: json['created'] as String,
);

Map<String, dynamic> _$SignatureToJson(Signature instance) => <String, dynamic>{
  'public_key_id': instance.public_key_id,
  'signature': instance.signature,
  'created': instance.created,
};

ConfigFile _$ConfigFileFromJson(Map<String, dynamic> json) =>
    ConfigFile(name: json['name'] as String, data: json['data'] as String);

Map<String, dynamic> _$ConfigFileToJson(ConfigFile instance) =>
    <String, dynamic>{'name': instance.name, 'data': instance.data};

GetPackageByVersionResponse _$GetPackageByVersionResponseFromJson(
  Map<String, dynamic> json,
) => GetPackageByVersionResponse(
  name: json['name'] as String,
  scope: json['scope'] as String?,
  description: json['description'] as String?,
  version: json['version'] as String,
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  contributors: (json['contributors'] as List<dynamic>?)
      ?.map((e) => Contributor.fromJson(e as Map<String, dynamic>))
      .toList(),
  language: json['language'] as String?,
  created_at: json['created_at'] as String,
  info: json['info'] as Map<String, dynamic>,
  env: json['env'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
  signatures: (json['signatures'] as List<dynamic>?)
      ?.map((e) => Signature.fromJson(e as Map<String, dynamic>))
      .toList(),
  deprecated: json['deprecated'] as bool?,
  deprecationMessage: json['deprecationMessage'] as String?,
  yanked: json['yanked'] as bool?,
  readme: json['readme'] as String?,
  config: json['config'] == null
      ? null
      : ConfigFile.fromJson(json['config'] as Map<String, dynamic>),
  hash: json['hash'] as String?,
  integrity: json['integrity'] as String?,
);

Map<String, dynamic> _$GetPackageByVersionResponseToJson(
  GetPackageByVersionResponse instance,
) => <String, dynamic>{
  'name': instance.name,
  'scope': ?instance.scope,
  'description': ?instance.description,
  'version': instance.version,
  'author': instance.author,
  'contributors': ?instance.contributors,
  'language': ?instance.language,
  'created_at': instance.created_at,
  'info': instance.info,
  'env': instance.env,
  'metadata': instance.metadata,
  'signatures': ?instance.signatures,
  'deprecated': ?instance.deprecated,
  'deprecationMessage': ?instance.deprecationMessage,
  'yanked': ?instance.yanked,
  'readme': ?instance.readme,
  'config': ?instance.config,
  'hash': ?instance.hash,
  'integrity': ?instance.integrity,
};

VerbosePackage _$VerbosePackageFromJson(Map<String, dynamic> json) =>
    VerbosePackage(
      name: json['name'] as String,
      scope: json['scope'] as String?,
      description: json['description'] as String?,
      version: json['version'] as String,
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      language: json['language'] as String?,
      created_at: json['created_at'] as String,
      updated_at: json['updated_at'] as String?,
      readme: json['readme'] as String?,
      info: json['info'] as Map<String, dynamic>,
      env: json['env'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
      signatures: (json['signatures'] as List<dynamic>?)
          ?.map((e) => Signature.fromJson(e as Map<String, dynamic>))
          .toList(),
      deprecated: json['deprecated'] as bool?,
      yanked: json['yanked'] as bool?,
    );

Map<String, dynamic> _$VerbosePackageToJson(VerbosePackage instance) =>
    <String, dynamic>{
      'name': instance.name,
      'scope': ?instance.scope,
      'description': ?instance.description,
      'version': instance.version,
      'author': instance.author,
      'language': ?instance.language,
      'created_at': instance.created_at,
      'updated_at': ?instance.updated_at,
      'readme': ?instance.readme,
      'info': instance.info,
      'env': instance.env,
      'metadata': instance.metadata,
      'signatures': ?instance.signatures,
      'deprecated': ?instance.deprecated,
      'yanked': ?instance.yanked,
    };

GetPackageResponse _$GetPackageResponseFromJson(Map<String, dynamic> json) =>
    GetPackageResponse(
      name: json['name'] as String,
      latest_version: json['latest_version'] as String,
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      description: json['description'] as String?,
      contributors: (json['contributors'] as List<dynamic>?)
          ?.map((e) => Contributor.fromJson(e as Map<String, dynamic>))
          .toList(),
      language: json['language'] as String?,
      license: json['license'] as String,
      vcs: $enumDecode(_$VCSEnumMap, json['vcs']),
      vcs_url: json['vcs_url'] as String?,
      created_at: json['created_at'] as String,
      updated_at: json['updated_at'] as String,
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
      'description': ?instance.description,
      'contributors': ?instance.contributors,
      'language': ?instance.language,
      'license': instance.license,
      'vcs': _$VCSEnumMap[instance.vcs]!,
      'vcs_url': ?instance.vcs_url,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
      'latest': instance.latest,
      'versions': instance.versions,
    };

const _$VCSEnumMap = {
  VCS.git: 'git',
  VCS.svn: 'svn',
  VCS.fossil: 'fossil',
  VCS.mercurial: 'mercurial',
  VCS.other: 'other',
};

Package _$PackageFromJson(Map<String, dynamic> json) => Package(
  name: json['name'] as String,
  scope: json['scope'] as String?,
  description: json['description'] as String?,
  version: json['version'] as String,
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  language: json['language'] as String?,
  created_at: json['created_at'] as String,
  updated_at: json['updated_at'] as String?,
);

Map<String, dynamic> _$PackageToJson(Package instance) => <String, dynamic>{
  'name': instance.name,
  'scope': ?instance.scope,
  'description': ?instance.description,
  'version': instance.version,
  'author': instance.author,
  'language': ?instance.language,
  'created_at': instance.created_at,
  'updated_at': ?instance.updated_at,
};

GetPackagesResponse _$GetPackagesResponseFromJson(Map<String, dynamic> json) =>
    GetPackagesResponse(
      next_url: json['next_url'] as String?,
      packages: (json['packages'] as List<dynamic>?)
          ?.map((e) => Package.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetPackagesResponseToJson(
  GetPackagesResponse instance,
) => <String, dynamic>{
  'next_url': ?instance.next_url,
  'packages': ?instance.packages,
};

GetScopeResponse _$GetScopeResponseFromJson(Map<String, dynamic> json) =>
    GetScopeResponse(
      name: json['name'] as String,
      is_member: json['is_member'] as bool,
    );

Map<String, dynamic> _$GetScopeResponseToJson(GetScopeResponse instance) =>
    <String, dynamic>{'name': instance.name, 'is_member': instance.is_member};

GetUserResponse _$GetUserResponseFromJson(Map<String, dynamic> json) =>
    GetUserResponse(
      name: json['name'] as String,
      email: json['email'] as String,
      created_at: json['created_at'] as String,
      updated_at: json['updated_at'] as String,
      packages: (json['packages'] as List<dynamic>?)
          ?.map((e) => PackageMap.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetUserResponseToJson(GetUserResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
      'packages': ?instance.packages,
    };

GetUsersResponse _$GetUsersResponseFromJson(Map<String, dynamic> json) =>
    GetUsersResponse();

Map<String, dynamic> _$GetUsersResponseToJson(GetUsersResponse instance) =>
    <String, dynamic>{};

InvalidError _$InvalidErrorFromJson(Map<String, dynamic> json) => InvalidError(
  error: json['error'] as String?,
  description: json['description'] as String?,
  redirect: json['redirect'] as String?,
);

Map<String, dynamic> _$InvalidErrorToJson(InvalidError instance) =>
    <String, dynamic>{
      'error': ?instance.error,
      'description': ?instance.description,
      'redirect': ?instance.redirect,
    };

InvalidTarballError _$InvalidTarballErrorFromJson(Map<String, dynamic> json) =>
    InvalidTarballError(
      error: json['error'] as String?,
      description: json['description'] as String,
      sanction: json['sanction'] as bool,
      violations_remaining: (json['violations_remaining'] as num?)?.toInt(),
    );

Map<String, dynamic> _$InvalidTarballErrorToJson(
  InvalidTarballError instance,
) => <String, dynamic>{
  'error': ?instance.error,
  'description': instance.description,
  'sanction': instance.sanction,
  'violations_remaining': ?instance.violations_remaining,
};

NotFoundError _$NotFoundErrorFromJson(Map<String, dynamic> json) =>
    NotFoundError(
      error: json['error'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$NotFoundErrorToJson(NotFoundError instance) =>
    <String, dynamic>{'error': ?instance.error, 'message': ?instance.message};

Configuration _$ConfigurationFromJson(Map<String, dynamic> json) =>
    Configuration(
      path: json['path'] as String,
      config: json['config'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ConfigurationToJson(Configuration instance) =>
    <String, dynamic>{'path': instance.path, 'config': ?instance.config};

VersionControlSystem _$VersionControlSystemFromJson(
  Map<String, dynamic> json,
) => VersionControlSystem(
  name: $enumDecode(_$VCSEnumMap, json['name']),
  url: json['url'] as String?,
);

Map<String, dynamic> _$VersionControlSystemToJson(
  VersionControlSystem instance,
) => <String, dynamic>{
  'name': _$VCSEnumMap[instance.name]!,
  'url': ?instance.url,
};

PublishPackageByVersionRequest _$PublishPackageByVersionRequestFromJson(
  Map<String, dynamic> json,
) => PublishPackageByVersionRequest(
  name: json['name'] as String,
  scope: json['scope'] as String?,
  version: json['version'] as String,
  language: json['language'] as String,
  config: Configuration.fromJson(json['config'] as Map<String, dynamic>),
  info: json['info'] as Map<String, dynamic>?,
  env: json['env'] as Map<String, dynamic>?,
  vcs: json['vcs'] == null
      ? null
      : VersionControlSystem.fromJson(json['vcs'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PublishPackageByVersionRequestToJson(
  PublishPackageByVersionRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'scope': ?instance.scope,
  'version': instance.version,
  'language': instance.language,
  'config': instance.config,
  'info': ?instance.info,
  'env': ?instance.env,
  'vcs': ?instance.vcs,
};

Queue _$QueueFromJson(Map<String, dynamic> json) => Queue(
  id: json['id'] as String,
  status: $enumDecode(_$PublishingStatusEnumMap, json['status']),
);

Map<String, dynamic> _$QueueToJson(Queue instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$PublishingStatusEnumMap[instance.status]!,
};

const _$PublishingStatusEnumMap = {
  PublishingStatus.pending: 'pending',
  PublishingStatus.error: 'error',
  PublishingStatus.success: 'success',
  PublishingStatus.idle: 'idle',
  PublishingStatus.queue: 'queue',
};

PublishPackageByVersionResponse _$PublishPackageByVersionResponseFromJson(
  Map<String, dynamic> json,
) => PublishPackageByVersionResponse(
  url: json['url'] as String?,
  queue: Queue.fromJson(json['queue'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PublishPackageByVersionResponseToJson(
  PublishPackageByVersionResponse instance,
) => <String, dynamic>{'url': ?instance.url, 'queue': instance.queue};

PublishPackageRequest _$PublishPackageRequestFromJson(
  Map<String, dynamic> json,
) => PublishPackageRequest(
  name: json['name'] as String,
  scope: json['scope'] as String?,
  version: json['version'] as String,
  language: json['language'] as String,
  config: Configuration.fromJson(json['config'] as Map<String, dynamic>),
  info: json['info'] as Map<String, dynamic>?,
  env: json['env'] as Map<String, dynamic>?,
  vcs: json['vcs'] == null
      ? null
      : VersionControlSystem.fromJson(json['vcs'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PublishPackageRequestToJson(
  PublishPackageRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'scope': ?instance.scope,
  'version': instance.version,
  'language': instance.language,
  'config': instance.config,
  'info': ?instance.info,
  'env': ?instance.env,
  'vcs': ?instance.vcs,
};

PublishPackageResponse _$PublishPackageResponseFromJson(
  Map<String, dynamic> json,
) => PublishPackageResponse(
  url: json['url'] as String?,
  queue: Queue.fromJson(json['queue'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PublishPackageResponseToJson(
  PublishPackageResponse instance,
) => <String, dynamic>{'url': ?instance.url, 'queue': instance.queue};

PublishPackageStatusResponse _$PublishPackageStatusResponseFromJson(
  Map<String, dynamic> json,
) => PublishPackageStatusResponse(
  status: $enumDecode(_$PublishingStatusEnumMap, json['status']),
  error: json['error'] as String?,
  description: json['description'] as String?,
  name: json['name'] as String,
  scope: json['scope'] as String?,
  version: json['version'] as String,
);

Map<String, dynamic> _$PublishPackageStatusResponseToJson(
  PublishPackageStatusResponse instance,
) => <String, dynamic>{
  'status': _$PublishingStatusEnumMap[instance.status]!,
  'error': ?instance.error,
  'description': ?instance.description,
  'name': instance.name,
  'scope': ?instance.scope,
  'version': instance.version,
};

RemovePackageByVersionRequest _$RemovePackageByVersionRequestFromJson(
  Map<String, dynamic> json,
) => RemovePackageByVersionRequest(
  reason: json['reason'] as String?,
  yank: json['yank'] as bool?,
  alternative: json['alternative'] as String?,
);

Map<String, dynamic> _$RemovePackageByVersionRequestToJson(
  RemovePackageByVersionRequest instance,
) => <String, dynamic>{
  'reason': ?instance.reason,
  'yank': ?instance.yank,
  'alternative': ?instance.alternative,
};

RemovePackageByVersionResponse _$RemovePackageByVersionResponseFromJson(
  Map<String, dynamic> json,
) => RemovePackageByVersionResponse(
  success: json['success'] as bool,
  reason: json['reason'] as String?,
  package_name: json['package_name'] as String,
  alternative: json['alternative'] as String?,
  request_type: $enumDecode(_$RequestTypeEnumMap, json['request_type']),
);

Map<String, dynamic> _$RemovePackageByVersionResponseToJson(
  RemovePackageByVersionResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'reason': ?instance.reason,
  'package_name': instance.package_name,
  'alternative': ?instance.alternative,
  'request_type': _$RequestTypeEnumMap[instance.request_type]!,
};

const _$RequestTypeEnumMap = {
  RequestType.yank: 'yank',
  RequestType.deprecate: 'deprecate',
};

RemovePackageRequest _$RemovePackageRequestFromJson(
  Map<String, dynamic> json,
) => RemovePackageRequest(
  reason: json['reason'] as String?,
  yank: json['yank'] as bool?,
  alternative: json['alternative'] as String?,
  version: json['version'] as String?,
);

Map<String, dynamic> _$RemovePackageRequestToJson(
  RemovePackageRequest instance,
) => <String, dynamic>{
  'reason': ?instance.reason,
  'yank': ?instance.yank,
  'alternative': ?instance.alternative,
  'version': ?instance.version,
};

RemovePackageResponse _$RemovePackageResponseFromJson(
  Map<String, dynamic> json,
) => RemovePackageResponse(
  success: json['success'] as bool,
  reason: json['reason'] as String?,
  package_name: json['package_name'] as String,
  alternative: json['alternative'] as String?,
  request_type: $enumDecode(_$RequestTypeEnumMap, json['request_type']),
  version: json['version'] as String,
);

Map<String, dynamic> _$RemovePackageResponseToJson(
  RemovePackageResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'reason': ?instance.reason,
  'package_name': instance.package_name,
  'alternative': ?instance.alternative,
  'request_type': _$RequestTypeEnumMap[instance.request_type]!,
  'version': instance.version,
};

ServerError _$ServerErrorFromJson(Map<String, dynamic> json) =>
    ServerError(error: json['error'] as String?);

Map<String, dynamic> _$ServerErrorToJson(ServerError instance) =>
    <String, dynamic>{'error': ?instance.error};

UnauthorizedError _$UnauthorizedErrorFromJson(Map<String, dynamic> json) =>
    UnauthorizedError(
      error: json['error'] as String?,
      reason: $enumDecodeNullable(_$UnauthorizedReasonEnumMap, json['reason']),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$UnauthorizedErrorToJson(UnauthorizedError instance) =>
    <String, dynamic>{
      'error': ?instance.error,
      'reason': ?_$UnauthorizedReasonEnumMap[instance.reason],
      'description': ?instance.description,
    };

const _$UnauthorizedReasonEnumMap = {
  UnauthorizedReason.protected: 'protected',
  UnauthorizedReason.org: 'org',
  UnauthorizedReason.package_access: 'package_access',
  UnauthorizedReason.other: 'other',
};

UploadAdapterResponse _$UploadAdapterResponseFromJson(
  Map<String, dynamic> json,
) => UploadAdapterResponse();

Map<String, dynamic> _$UploadAdapterResponseToJson(
  UploadAdapterResponse instance,
) => <String, dynamic>{};

UploadPackageResponse _$UploadPackageResponseFromJson(
  Map<String, dynamic> json,
) => UploadPackageResponse();

Map<String, dynamic> _$UploadPackageResponseToJson(
  UploadPackageResponse instance,
) => <String, dynamic>{};

YankAdapterResponse _$YankAdapterResponseFromJson(Map<String, dynamic> json) =>
    YankAdapterResponse(reason: json['reason'] as String?);

Map<String, dynamic> _$YankAdapterResponseToJson(
  YankAdapterResponse instance,
) => <String, dynamic>{'reason': ?instance.reason};

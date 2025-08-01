// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetLatestPackageRequest _$GetLatestPackageRequestFromJson(
  Map<String, dynamic> json,
) => GetLatestPackageRequest(
  name: json['name'] as String,
  options: json['options'] == null
      ? null
      : PackageOptions.fromJson(json['options'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GetLatestPackageRequestToJson(
  GetLatestPackageRequest instance,
) => <String, dynamic>{'name': instance.name, 'options': instance.options};

Map<String, dynamic> _$GetLatestPackageResponseToJson(
  GetLatestPackageResponse instance,
) => <String, dynamic>{
  'package': const PackageVersionsConverter().toJson(instance.package),
};

GetPackageWithVersionRequest _$GetPackageWithVersionRequestFromJson(
  Map<String, dynamic> json,
) => GetPackageWithVersionRequest(
  name: json['name'] as String,
  version: json['version'] as String,
  options: json['options'] == null
      ? null
      : PackageOptions.fromJson(json['options'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GetPackageWithVersionRequestToJson(
  GetPackageWithVersionRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'version': instance.version,
  'options': instance.options,
};

Map<String, dynamic> _$GetPackageWithVersionResponseToJson(
  GetPackageWithVersionResponse instance,
) => <String, dynamic>{
  'package': const PackageVersionsConverter().toJson(instance.package),
};

GetPackagesRequest _$GetPackagesRequestFromJson(Map<String, dynamic> json) =>
    GetPackagesRequest(
      name: json['name'] as String,
      options: json['options'] == null
          ? null
          : PackageOptions.fromJson(json['options'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetPackagesRequestToJson(GetPackagesRequest instance) =>
    <String, dynamic>{'name': instance.name, 'options': instance.options};

Map<String, dynamic> _$GetPackagesResponseToJson(
  GetPackagesResponse instance,
) => <String, dynamic>{
  'package_versions': const PackageVersionsMapConverter().toJson(
    instance.packageVersions,
  ),
};

GetPackageDetailsRequest _$GetPackageDetailsRequestFromJson(
  Map<String, dynamic> json,
) => GetPackageDetailsRequest(
  name: json['name'] as String,
  options: json['options'] == null
      ? null
      : PackageOptions.fromJson(json['options'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GetPackageDetailsRequestToJson(
  GetPackageDetailsRequest instance,
) => <String, dynamic>{'name': instance.name, 'options': instance.options};

Map<String, dynamic> _$GetPackageDetailsResponseToJson(
  GetPackageDetailsResponse instance,
) => <String, dynamic>{'package': instance.package};

GetPackageContributorsRequest _$GetPackageContributorsRequestFromJson(
  Map<String, dynamic> json,
) => GetPackageContributorsRequest(
  name: json['name'] as String,
  options: json['options'] == null
      ? null
      : PackageOptions.fromJson(json['options'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GetPackageContributorsRequestToJson(
  GetPackageContributorsRequest instance,
) => <String, dynamic>{'name': instance.name, 'options': instance.options};

Map<String, dynamic> _$GetPackageContributorsResponseToJson(
  GetPackageContributorsResponse instance,
) => <String, dynamic>{'contributors': instance.contributors};

GetArchiveWithVersionRequest _$GetArchiveWithVersionRequestFromJson(
  Map<String, dynamic> json,
) => GetArchiveWithVersionRequest(
  name: json['name'] as String,
  version: json['version'] as String,
  language: json['language'] as String?,
);

Map<String, dynamic> _$GetArchiveWithVersionRequestToJson(
  GetArchiveWithVersionRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'version': instance.version,
  'language': instance.language,
};

Map<String, dynamic> _$GetArchiveWithVersionResponseToJson(
  GetArchiveWithVersionResponse instance,
) => <String, dynamic>{
  'name': instance.name,
  'contentType': instance.contentType,
  'data': instance.data,
};

Map<String, dynamic> _$GetRawArchiveWithVersionResponseToJson(
  GetRawArchiveWithVersionResponse instance,
) => <String, dynamic>{
  'name': instance.name,
  'contentType': instance.contentType,
  'data': instance.data,
};

PackageOptions _$PackageOptionsFromJson(Map<String, dynamic> json) =>
    PackageOptions(
      language: json['language'] as String?,
      env: json['env'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PackageOptionsToJson(PackageOptions instance) =>
    <String, dynamic>{'language': instance.language, 'env': instance.env};

Map<String, dynamic> _$UserEntryToJson(UserEntry instance) => <String, dynamic>{
  'user': const UserJsonConverter().toJson(instance.user),
  'privileges': instance.privileges
      .map((e) => _$PrivilegesEnumMap[e]!)
      .toList(),
};

const _$PrivilegesEnumMap = {
  Privileges.read: 'read',
  Privileges.write: 'write',
  Privileges.publish: 'publish',
  Privileges.ultimate: 'ultimate',
};

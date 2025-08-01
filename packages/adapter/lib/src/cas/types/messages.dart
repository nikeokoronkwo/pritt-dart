import 'dart:typed_data';

import 'package:chunked_stream/chunked_stream.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_server_core/pritt_server_core.dart';

import 'converters.dart';

part 'messages.g.dart';

@JsonSerializable()
class GetLatestPackageRequest {
  final String name;

  final PackageOptions? options;

  GetLatestPackageRequest({required this.name, this.options});

  factory GetLatestPackageRequest.fromJson(Map<String, dynamic> json) =>
      _$GetLatestPackageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetLatestPackageRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class GetLatestPackageResponse {
  @PackageVersionsConverter()
  final PackageVersions package;

  GetLatestPackageResponse({required this.package});

  Map<String, dynamic> toJson() => _$GetLatestPackageResponseToJson(this);
}

@JsonSerializable()
class GetPackageWithVersionRequest {
  final String name;

  final String version;

  final PackageOptions? options;

  GetPackageWithVersionRequest({
    required this.name,
    required this.version,
    this.options,
  });

  factory GetPackageWithVersionRequest.fromJson(Map<String, dynamic> json) =>
      _$GetPackageWithVersionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetPackageWithVersionRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class GetPackageWithVersionResponse {
  @PackageVersionsConverter()
  final PackageVersions package;

  GetPackageWithVersionResponse({required this.package});

  Map<String, dynamic> toJson() => _$GetPackageWithVersionResponseToJson(this);
}

@JsonSerializable()
class GetPackagesRequest {
  final String name;

  final PackageOptions? options;

  GetPackagesRequest({required this.name, this.options});

  factory GetPackagesRequest.fromJson(Map<String, dynamic> json) =>
      _$GetPackagesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetPackagesRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class GetPackagesResponse {
  @JsonKey(name: 'package_versions')
  @PackageVersionsMapConverter()
  final Map<String, PackageVersions> packageVersions;

  GetPackagesResponse({required this.packageVersions});

  Map<String, dynamic> toJson() => _$GetPackagesResponseToJson(this);
}

@JsonSerializable()
class GetPackageDetailsRequest {
  final String name;

  final PackageOptions? options;

  GetPackageDetailsRequest({required this.name, this.options});

  factory GetPackageDetailsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetPackageDetailsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetPackageDetailsRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class GetPackageDetailsResponse {
  final Package package;

  GetPackageDetailsResponse({required this.package});

  Map<String, dynamic> toJson() => _$GetPackageDetailsResponseToJson(this);
}

@JsonSerializable()
class GetPackageContributorsRequest {
  final String name;

  final PackageOptions? options;

  GetPackageContributorsRequest({required this.name, this.options});

  factory GetPackageContributorsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetPackageContributorsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetPackageContributorsRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class GetPackageContributorsResponse {
  final List<UserEntry> contributors;

  GetPackageContributorsResponse({this.contributors = const []});

  Map<String, dynamic> toJson() => _$GetPackageContributorsResponseToJson(this);
}

@JsonSerializable()
class GetArchiveWithVersionRequest {
  final String name;

  final String version;

  final String? language;

  GetArchiveWithVersionRequest({
    required this.name,
    required this.version,
    this.language,
  });

  factory GetArchiveWithVersionRequest.fromJson(Map<String, dynamic> json) =>
      _$GetArchiveWithVersionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetArchiveWithVersionRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class GetArchiveWithVersionResponse {
  final String name;

  final String? contentType;

  final bool data;

  GetArchiveWithVersionResponse({
    required this.name,
    this.contentType,
    required this.data,
  });

  static Future<GetArchiveWithVersionResponse> fromArchive(
    CRSArchive archive,
  ) async => GetArchiveWithVersionResponse(
    name: archive.name,
    contentType: archive.contentType,
    data: (await readByteStream(archive.data)).isNotEmpty,
  );

  Map<String, dynamic> toJson() => _$GetArchiveWithVersionResponseToJson(this);
}

@JsonSerializable(createFactory: false)
class GetRawArchiveWithVersionResponse {
  final String name;

  final String? contentType;

  final Uint8List data;

  GetRawArchiveWithVersionResponse({
    required this.name,
    this.contentType,
    required this.data,
  });

  static Future<GetRawArchiveWithVersionResponse> fromArchive(
    CRSArchive archive,
  ) async => GetRawArchiveWithVersionResponse(
    name: archive.name,
    contentType: archive.contentType,
    data: await readByteStream(archive.data),
  );

  Map<String, dynamic> toJson() =>
      _$GetRawArchiveWithVersionResponseToJson(this);
}

// options
@JsonSerializable()
class PackageOptions {
  final String? language;

  final Map<String, dynamic>? env;

  PackageOptions({this.language, this.env});

  factory PackageOptions.fromJson(Map<String, dynamic> json) =>
      _$PackageOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$PackageOptionsToJson(this);
}

@JsonSerializable(createFactory: false)
class UserEntry {
  @UserJsonConverter()
  final User user;

  final List<Privileges> privileges;

  UserEntry({required this.user, this.privileges = const []});

  Map<String, dynamic> toJson() => _$UserEntryToJson(this);
}

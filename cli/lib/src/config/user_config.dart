import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as p;

import '../constants.dart';
import '../device_id.dart';

part 'user_config.g.dart';

/// The home directory of the system, assuming that you are using a supported desktop system
String get homeDirectory {
  if (Platform.isWindows) return Platform.environment['UserProfile']!;
  return Platform.environment['HOME']!;
}

/// User credential options: User data stored for indexing
@JsonSerializable()
class UserCredentials {
  /// The URL logged into, to access the Pritt instance
  Uri uri;

  /// The device ID
  @JsonKey(name: 'device_id')
  String deviceId;

  /// The access token for the current user
  @JsonKey(name: 'access_token')
  String accessToken;

  @JsonKey(name: 'user_id')
  String userId;

  /// When the access token expires
  @JsonKey(name: 'access_token_expires')
  DateTime accessTokenExpires;

  static final _file = File(p.join(homeDirectory, '.pritt', 'config.json'));

  String get path => _file.path;

  UserCredentials(
      {Uri? uri,
      required this.accessToken,
      required this.accessTokenExpires,
      required this.userId,
      required this.deviceId})
      : uri = uri ?? Uri.parse(mainPrittInstance);

  /// [duration] in seconds
  factory UserCredentials.fromExpirationDuration(
      {required String accessToken,
      required int duration,
      Uri? uri,
      required String id,
      required String deviceId}) {
    uri ??= Uri.parse(mainPrittInstance);

    final timeNow = DateTime.now();
    final timeExpiration = timeNow.add(Duration(seconds: duration));

    return UserCredentials(
        uri: uri,
        userId: id,
        accessToken: accessToken,
        accessTokenExpires: timeExpiration,
        deviceId: deviceId);
  }

  factory UserCredentials.fromJson(Map<String, dynamic> json) =>
      _$UserCredentialsFromJson(json);

  Map<String, dynamic> toJson() => _$UserCredentialsToJson(this);

  /// get user credentials from the user system
  ///
  // TODO(nikeokoronkwo): Consider secure way of storing information, https://github.com/nikeokoronkwo/pritt-dart/issues/57
  static Future<UserCredentials?> fetch() async {
    if (await _file.exists()) {
      return UserCredentials.fromJson(json.decode(await _file.readAsString()));
    }
    return null;
  }

  static Future<UserCredentials> create(String accessToken,
      {Uri? uri,
      int? accessTokenDuration,
      required String id,
      String? deviceId}) async {
    // give default duration of 3 months, in secs
    accessTokenDuration ??= (7 * 4 * 3) * (24 * 3600);

    // create or overwrite configuration file
    try {
      final credentialsObject = UserCredentials.fromExpirationDuration(
          accessToken: accessToken,
          duration: accessTokenDuration,
          uri: uri,
          id: id,
          deviceId: deviceId ?? await getDeviceId());

      if (!(await _file.parent.exists())) {
        await _file.parent.create(recursive: true);
      }

      await _file.writeAsString(json.encode(credentialsObject.toJson()));

      return credentialsObject;
    } catch (e) {
      rethrow;
    }
  }

  /// update user credentials on system
  Future<void> update() async {
    await _file.writeAsString(json.encode(toJson()));
  }

  void updateSync() {
    _file.writeAsStringSync(json.encode(toJson()));
  }

  /// replace user credentials with new credentials
  Future<UserCredentials> replace(
      {Uri? uri, String? accessToken, DateTime? accessTokenExpires}) async {
    if (uri != null) this.uri = uri;
    if (accessToken != null) this.accessToken = accessToken;
    if (accessTokenExpires != null) {
      this.accessTokenExpires = accessTokenExpires;
    }

    await update();

    return this;
  }

  void replaceSync(
      {Uri? uri, String? accessToken, DateTime? accessTokenExpires}) {
    if (uri != null) this.uri = uri;
    if (accessToken != null) this.accessToken = accessToken;
    if (accessTokenExpires != null) {
      this.accessTokenExpires = accessTokenExpires;
    }

    updateSync();
  }

  bool get isExpired => accessTokenExpires.isBefore(DateTime.now());
}

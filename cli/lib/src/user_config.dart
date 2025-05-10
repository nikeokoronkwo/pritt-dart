/// User credential options: User data stored for indexing
library;

import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_cli/src/constants.dart';

@JsonSerializable()
class UserCredentials {
  /// The URL logged into, to access the Pritt instance
  Uri uri;

  /// The access token for the current user
  @JsonKey(name: 'access_token')
  String accessToken;
  
  /// When the access token expires
  @JsonKey(name: 'access_token_expires')
  DateTime accessTokenExpires;

  UserCredentials({
    Uri? uri,
    required this.accessToken,
    required this.accessTokenExpires
  }) : uri = uri ?? Uri.parse(mainPrittInstance);

  factory UserCredentials.fromExpirationDuration({
    required String accessToken,
    required int duration,
    Uri? uri
  }) {
    uri ??= Uri.parse(mainPrittInstance);

    final timeNow = DateTime.now();
    final timeExpiration = timeNow.add(Duration());

    return UserCredentials(
      uri: uri, 
      accessToken: accessToken,
      accessTokenExpires: timeExpiration
    );
  }
}

UserCredentials? getUserCredentials() {
  throw UnimplementedError('UserCredentials not implemented');
}

UserCredentials loginUser() {
  throw UnimplementedError('UserCredentials not implemented');
}

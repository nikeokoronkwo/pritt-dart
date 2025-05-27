import 'dart:async';
import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_server/src/main/crs/exceptions.dart';
import 'package:pritt_server/src/utils/auth.dart';

part 'auth.g.dart';

abstract interface class PrittAuthInterface {
  /// Creates a new access token for the user.
  FutureOr<String> createAccessTokenForUser({
    required String name,
    required String email,
    required DateTime expiresAt,
  });

  /// Validates an access token and returns the user information if valid.
  FutureOr<PrittAuthMetadata> validateAccessToken(String token);
}

@JsonSerializable()
class PrittAuthMetadata {
  /// The name of the user
  final String name;

  /// The email of the user
  final String email;

  PrittAuthMetadata({
    required this.name,
    required this.email,
  });

  factory PrittAuthMetadata.fromJson(Map<String, dynamic> json) =>
      _$PrittAuthMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$PrittAuthMetadataToJson(this);
}

class PrittAuth implements PrittAuthInterface {
  final KeySet keySet;

  PrittAuth(this.keySet);

  @override
  String createAccessTokenForUser({
    required String name,
    required String email,
    required DateTime expiresAt,
  }) {
    // Implementation for creating an access token.
    final jwt = JWT({
      'name': name,
      'email': email,
    });

    final token = jwt.sign(
      keySet.privateKey,
      algorithm: JWTAlgorithm.RS512,
      expiresIn: expiresAt.difference(DateTime.now()),
    );

    return token;
  }

  @override
  PrittAuthMetadata validateAccessToken(String token) {
    try {
      final jwt = JWT.verify(
        token,
        keySet.publicKey,
      );

      final payload = jwt.payload;

      if (payload == null) {
        throw Exception('The token payload is undefined.');
      }

      if (payload is Map<String, dynamic>) {
        return PrittAuthMetadata.fromJson(payload);
      } else if (payload is String) {
        return PrittAuthMetadata.fromJson(
            jsonDecode(payload) as Map<String, dynamic>);
      } else {
        throw Exception('The token payload is not a valid object.');
      }
    } on JWTExpiredException catch (e) {
      throw ExpiredTokenException(
          'The access token has expired. Please log in again.',
          token: token);
    } on JWTNotActiveException catch (e) {
      throw JWTNotActiveException();
    } on JWTInvalidException catch (e) {
      throw JWTInvalidException(e.message);
    } on JWTParseException catch (e) {
      throw JWTParseException(e.message);
    } on JWTUndefinedException catch (e, stackTrace) {
      throw JWTUndefinedException(e, stackTrace);
    }
  }
}

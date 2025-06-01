import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_server/src/main/crs/exceptions.dart';

part 'auth.g.dart';

abstract interface class PrittAuthInterface<T> {
  /// Creates a new access token for the user.
  FutureOr<({String key, String hash})> createAccessTokenForUser({
    required String name,
    required String email,
    required DateTime expiresAt,
  });

  /// Validates an access token and returns the user information if valid.
  FutureOr<bool> validateAccessToken(String token, String hash);
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

@JsonSerializable()
class APIKeyResult {
  final String apiKey;
  final String keyHash;
  final DateTime createdAt;
  final String prefix;
  final int length;

  APIKeyResult({
    required this.apiKey,
    required this.keyHash,
    required this.createdAt,
    required this.prefix,
    required this.length,
  });

  factory APIKeyResult.fromJson(Map<String, dynamic> json) =>
      _$APIKeyResultFromJson(json);

  Map<String, dynamic> toJson() => _$APIKeyResultToJson(this);
}

class PrittAccessTokenGenerator {
  static final Random _secureRandom = Random.secure();

  static APIKeyResult hashAPIKey(String accessToken,
      {Map<String, dynamic>? info}) {
    final keyHash = sha256
        .convert(utf8.encode(accessToken + (info?.values.join('') ?? '')))
        .toString()
        .substring(0, 8);

    return APIKeyResult(
        apiKey: accessToken,
        keyHash: keyHash,
        createdAt: DateTime.now(),
        prefix: accessToken.substring(0, 3),
        length: accessToken.length);
  }

  static APIKeyResult generateAPIKey(String prefix, int length,
      {Map<String, dynamic>? info}) {
    final randomLength = length - prefix.length;

    final randomBytes = Uint8List(randomLength);
    for (int i = 0; i < randomLength; i++) {
      randomBytes[i] = _secureRandom.nextInt(256);
    }

    String randomPart = base64Encode(randomBytes)
        .replaceAll(RegExp(r'[+/=]'), '') // Remove problematic characters
        .substring(0, randomLength);

    while (randomPart.length < randomLength) {
      final additionalBytes = Uint8List(8);
      for (int i = 0; i < 8; i++) {
        additionalBytes[i] = _secureRandom.nextInt(256);
      }
      final additional =
          base64Encode(additionalBytes).replaceAll(RegExp(r'[+/=]'), '');
      randomPart += additional;
    }

    randomPart = randomPart.substring(0, randomLength);

    final apiKey = prefix + randomPart;

    final keyHash = sha256
        .convert(utf8.encode(apiKey + (info?.values.join('') ?? '')))
        .toString()
        .substring(0, 8);

    return APIKeyResult(
        apiKey: apiKey,
        keyHash: keyHash,
        createdAt: DateTime.now(),
        prefix: prefix,
        length: length);
  }

  static bool verifyAPIKey(String apiKey, String keyHash,
      {Map<String, dynamic>? info}) {
    final computedHash = sha256
        .convert(utf8.encode(apiKey + (info?.values.join('') ?? '')))
        .toString()
        .substring(0, 8);

    return computedHash == keyHash;
  }
}

class PrittAuth implements PrittAuthInterface<PrittAuthMetadata> {
  PrittAuth();

  @override
  ({String key, String hash}) createAccessTokenForUser({
    required String name,
    required String email,
    required DateTime expiresAt,
  }) {
    // Implementation for creating an access token.
    final meta = PrittAuthMetadata(name: name, email: email);

    final key = PrittAccessTokenGenerator.generateAPIKey('pt_', 20);

    return (key: key.apiKey, hash: key.keyHash);
    // todo: implement
  }

  @override
  bool validateAccessToken(String token, String hash) {
    return PrittAccessTokenGenerator.verifyAPIKey(token, hash);
  }

  String hashToken(String accessToken) {
    return PrittAccessTokenGenerator.hashAPIKey(accessToken).keyHash;
  }
}

import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

typedef KeySet = ({
  RSAPrivateKey privateKey,
  RSAPublicKey publicKey,
});
Future<KeySet> loadKeySet() async {
  final privateKeyFile = File(String.fromEnvironment('PRIVATE_KEY_FILE',
      defaultValue: 'private_key.pem'));
  final publicKeyFile = File(String.fromEnvironment('PUBLIC_KEY_FILE',
      defaultValue: 'public_key.pem'));

  if (!privateKeyFile.existsSync() || !publicKeyFile.existsSync()) {
    throw Exception(
        'Private or public key file does not exist. Please check the environment variables PRIVATE_KEY_FILE and PUBLIC_KEY_FILE.');
  }

  final privateKey = RSAPrivateKey(privateKeyFile.readAsStringSync());
  final publicKey = RSAPublicKey(publicKeyFile.readAsStringSync());

  return (privateKey: privateKey, publicKey: publicKey);
}

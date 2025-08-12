import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:ffi/ffi.dart';
import 'package:openssl_ecdsa/openssl_ecdsa.dart';
import 'package:openssl_ecdsa/src/native/openssl.dart';
import 'package:test/test.dart';

void main() {
  group('OpenSSL ECDSA Signing Test', () {
    const message = "sign this";
    late final OpenSSL openSSL = OpenSSL(loadOpenSSL());

    test('Signing', () {
      openSSL.OPENSSL_init_crypto(OPENSSL_INIT_LOAD_CONFIG, ffi.nullptr);
      // create key object
      final ecKey = openSSL.EC_KEY_new_by_curve_name(NID_X9_62_prime256v1);

      if (ecKey == ffi.nullptr) {
        openSSL.ERR_print_errors_fp(openSSL.stderrp);
        return;
      }

      if (openSSL.EC_KEY_generate_key(ecKey) != 1) {
        openSSL.ERR_print_errors_fp(openSSL.stderrp);
        return;
      }

      final digest = sha256.convert(
        utf8.encode(message)
      );

      final hash = digest.bytes;
      final hashBytes = Uint8List.fromList(hash);

      final hashPtr = malloc<ffi.Uint8>(hashBytes.length);
      final hashNative = hashPtr.asTypedList(hashBytes.length);
      hashNative.setAll(0, hashBytes);

      final signature = openSSL.ECDSA_do_sign(hashPtr.cast<ffi.UnsignedChar>(), hash.length, ecKey);

      // verify signature
      final ret = openSSL.ECDSA_do_verify(
        hashPtr.cast<ffi.UnsignedChar>(), 
        hash.length, signature, ecKey
      );

      if (ret == -1) {
        print('Error verifying signature');
      } else if (ret == 0) {
        print('Signature invalid');
      } else {
        print('Signature ok');
      }

      if (signature == ffi.nullptr) {
        print('Error');
        return;
      }

      final rPtrPtr = calloc<ffi.Pointer<BIGNUM>>();
      final sPtrPtr = calloc<ffi.Pointer<BIGNUM>>();

      openSSL.ECDSA_SIG_get0(signature, rPtrPtr, sPtrPtr);

      final r = rPtrPtr.value;
      final s = sPtrPtr.value;

      // Convert to hex
      final rHexPtr = openSSL.BN_bn2hex(r);
      final sHexPtr = openSSL.BN_bn2hex(s);

      final rHex = rHexPtr.cast<Utf8>().toDartString();
      final sHex = sHexPtr.cast<Utf8>().toDartString();

      print('r: $rHex');
      print('s: $sHex');

      malloc.free(hashPtr);
      calloc.free(rPtrPtr);
      calloc.free(sPtrPtr);
      openSSL.EC_KEY_free(ecKey);

      
    });

  });
}
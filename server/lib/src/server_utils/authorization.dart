import 'package:pritt_server/pritt_server.dart';
import 'package:pritt_server/src/main/crs/crs_db.dart';
import 'package:pritt_server/src/main/crs/db/schema.dart';

Future<User?> checkAuthorization(String authHeader,
    {bool throwExceptions = false}) async {
  final token =
      authHeader.startsWith('Bearer ') ? authHeader.substring(7) : authHeader;
  // check if the token is valid
  try {
    final user = await crs.db.checkAuthorization(token);
    if (user == null) {
      return null;
    }
    return user;
  } catch (e) {
    if (throwExceptions) rethrow;
    return null;
  }
}

import 'package:pritt_server_core/pritt_server_core.dart';

import '../crs.dart';

Future<User?> checkAuthorization(
  String authHeader, {
  bool throwExceptions = false,
}) async {
  final token = authHeader.startsWith('Bearer ')
      ? authHeader.substring(7)
      : authHeader;
  // check if the token is valid
  try {
    final authResults = await crs.db.checkAuthorization(token);
    if (authResults == null) {
      return null;
    }

    return authResults;
  } catch (e) {
    if (throwExceptions) rethrow;
    return null;
  }
}

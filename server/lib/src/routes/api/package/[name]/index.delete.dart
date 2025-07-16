
import 'dart:convert';

import 'package:pritt_common/interface.dart' as common;

import '../../../../../pritt_server.dart';
import '../../../../main/crs/exceptions.dart';
import '../../../../server_utils/authorization.dart';
import '../../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // parse info
  final pkgName = getParams(event, 'name') as String;

  try {
    // check if user is authenticated
    final authHeader = getHeader(event, 'Authorization');
    final user = authHeader == null
        ? null
        : await checkAuthorization(authHeader);

    if (user == null) {
      setResponseCode(event, 401);
      return common.UnauthorizedError(error: 'UnauthorizedError').toJson();
    }

    final body = await getBody(
      event,
      (s) => common.RemovePackageRequest.fromJson(json.decode(s)),
    );

    final pkgDetails = await crs.db.getPackage(pkgName);
    final pkgs = await crs.db.getAllVersionsOfPackage(pkgName);
    

  } on CRSException catch (e) {

  } on AssertionError catch (e) {
    setResponseCode(event, 400);
    return common.Error(
      error: e.message.toString(),
    ).toJson();
  } catch (e) {
    setResponseCode(event, 500);
    return common.ServerError(error: e.toString()).toJson();
  }
});
import 'package:pritt_common/interface.dart' as common;

import '../../../../utils/authorization.dart';
import '../../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // check authorization
  final authToken = getHeader(event, 'Authorization');
  final auth = authToken == null ? null : await checkAuthorization(authToken);

  if (auth == null) {
    setResponseCode(event, 401);
    return common.UnauthorizedError(
      error: 'Unauthorized',
      description: 'You are not authorized to view or use this endpoint',
    ).toJson();
  }
});

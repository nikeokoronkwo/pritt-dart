import '../../../../server_utils/authorization.dart';
import '../../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // check authorization
  final authToken = getHeader(event, 'Authorization');
  final auth = await checkAuthorization(authToken);

  if (auth != null) {
    setResponseCode(event, 401);
    return {
      'error': 'Unauthorized',
      'message': 'You are not authorized to view or use this endpoint'
    };
  }
});

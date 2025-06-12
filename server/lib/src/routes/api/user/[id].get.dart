import '../../../../pritt_server.dart';
import '../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  try {
    final id = getParams(event, 'id') as String;

    final user = await crs.db.getUser(id);
  } catch (e) {}
});

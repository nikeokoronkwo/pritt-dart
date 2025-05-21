

import 'package:pritt_server/pritt_server.dart';
import 'package:pritt_server/src/main/crs/exceptions.dart';
import 'package:pritt_server/src/utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  try {
    final id = getParams(event, 'id') as String;

    final user = await crs.db.getUser(id);

    
  
  } on CRSException catch (e) {
    
  } on Exception catch (e) {
    
  }

  
});
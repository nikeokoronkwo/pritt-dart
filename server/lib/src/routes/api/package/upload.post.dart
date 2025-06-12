import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart';
import 'package:pritt_common/interface.dart' as common;
import '../../../server_utils/authorization.dart';
import '../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // check authorization
  final authToken = getHeader(event, 'Authorization');
  final auth = await checkAuthorization(authToken);

  if (auth != null) {
    setResponseCode(event, 401);
    return common.UnauthorizedError(
            error: 'You are not authorized to view or use this endpoint')
        .toJson();
  }

  // get the tarball from the body
  final bodyBytes = getStreamedBody(event);

  // read the tarball
  final tarballReader = TarDecoder().decodeBytes(
      await ByteStream(bodyBytes.transform(gzip.decoder)).toBytes());

  // place tarball in bucket temporarily

  // insert into publishing queue
});

import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:chunked_stream/chunked_stream.dart';
import 'package:http/http.dart';
import 'package:pritt_common/functions.dart';
import 'package:pritt_common/interface.dart' as common;
import '../../../../pritt_server.dart';
import '../../../main/crs/exceptions.dart';
import '../../../server_utils/authorization.dart';
import '../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // check authorization
  final authToken = getHeader(event, 'Authorization');
  final auth = await checkAuthorization(authToken);

  if (auth == null) {
    setResponseCode(event, 401);
    return common.UnauthorizedError(
            error: 'You are not authorized to view or use this endpoint')
        .toJson();
  }

  // get the tarball from the body
  final bodyStream = getStreamedBody(event).asBroadcastStream();

  // get the pub id
  final pubID = getQueryParams(event)['id'] as String;

  try {
    // read the tarball
    final archive = TarDecoder().decodeBytes(
        await ByteStream(bodyStream.cast<List<int>>().transform(gzip.decoder))
            .toBytes());

    print('=' * 100);
    print('Archive: ${archive.length} : ${archive.map((f) => (
          f.name,
          f.content.runtimeType
        ))} --> $archive');

    // check if empty
    if (archive.isEmpty) {
      setResponseCode(event, 403);
      return common.InvalidTarballError(
              error: 'InvalidTarballError',
              description: 'The tarball is empty',
              sanction: false)
          .toJson();
    }

    if (archive.any((f) => f.isSymbolicLink && f.name.startsWith('..'))) {
      setResponseCode(event, 403);
      return common.InvalidTarballError(
              description:
                  'The tarball contains recursive, external paths. This was not made using the Pritt CLI',
              sanction: true,
              error: 'InvalidTarballError')
          .toJson();
    }

    // TODO: allow restrictions for people to have more than max
    int totalSize = archive.files.fold(0, (sum, f) => sum + f.size);
    if (totalSize > maxTarballSize) {
      setResponseCode(event, 403);
      return common.InvalidTarballError(
              description: 'Tarball too large',
              sanction: false,
              error: 'InvalidTarballError')
          .toJson();
    }

    // get the pub task associated with this
    final taskInfo = await crs.db.getPublishingTaskById(pubID);

    final tarballName = archivePath(taskInfo.name,
        version: taskInfo.version, scope: taskInfo.scope);

    print(tarballName);

    // place tarball in bucket temporarily
    final bodyBytes = GZipEncoder().encode(TarEncoder().encode(archive))!;

    await crs.ofs.createPubArchive(tarballName, Uint8List.fromList(bodyBytes));

    setResponseCode(event, 204);
    return null;
  } on CRSException catch (e, st) {
    print('${e.message} : ${e.cause} : ${e.stackTrace} -- $st');
    switch (e.type) {
      case CRSExceptionType.ITEM_NOT_FOUND:
        setResponseCode(event, 404);
        return common.NotFoundError(message: e.message).toJson();
      default:
        setResponseCode(event, 500);
        return common.ServerError(error: e.message).toJson();
    }
  } catch (e, st) {
    print('$e -- $st');
    setResponseCode(event, 500);
    return common.ServerError(error: 'Server Error').toJson();
  }

  // insert into publishing queue
});

const maxTarballSize = 20 * 1024 * 1024;

Future<int> getStreamLength(Stream<List<int>> stream) async {
  int totalLength = 0;
  await for (final chunk in stream) {
    totalLength += chunk.length;
  }
  return totalLength;
}

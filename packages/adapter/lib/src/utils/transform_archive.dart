import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:async/async.dart';
import 'package:pritt_server_core/pritt_server_core.dart';

Future<Uint8List> transformTarToZip(
  CRSArchive crsArchive, {
  String? basePath,
}) async {
  final archive = TarDecoder().decodeBytes(
    GZipDecoder().decodeBytes(await collectBytes(crsArchive.data)),
  );

  final Archive outArchive = Archive();

  for (final archiveFile in archive) {
    outArchive.addFile(
      ArchiveFile(
        [
          ?basePath,
          // name,
          archiveFile.name,
        ].join('/'),
        archiveFile.size,
        archiveFile.content,
        archiveFile.compressionType,
      ),
    );
  }

  final zipArchive = ZipEncoder().encode(outArchive) ?? [];
  return Uint8List.fromList(zipArchive);
}

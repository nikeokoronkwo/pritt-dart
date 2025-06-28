import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

Future<void> safeExtractTarGz({
  required File tarGzFile,
  required Directory outputDirectory,
  int maxTotalSizeBytes = 100 * 1024 * 1024, // 100MB
}) async {
  final compressedBytes = await tarGzFile.readAsBytes();
  final archive =
      TarDecoder().decodeBytes(GZipDecoder().decodeBytes(compressedBytes));

  int totalSize = 0;

  for (final file in archive) {
    final safePath = sanitizeFilename(outputDirectory.path, file.name);

    if (file.isFile) {
      totalSize += file.size;
      if (totalSize > maxTotalSizeBytes) {
        throw Exception('Total size exceeds limit.');
      }

      final outFile = File(safePath);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>);
    } else {
      final dir = Directory(safePath);
      await dir.create(recursive: true);
    }
  }
}

String sanitizeFilename(String targetDir, String filePath) {
  final fullPath = File(
          '$targetDir/${p.relative(filePath, from: filePath.split('/').first)}')
      .absolute
      .path;
  final safeRoot = Directory(targetDir).absolute.path;

  if (!fullPath.startsWith(safeRoot)) {
    throw Exception('Blocked path traversal attempt: $filePath');
  }

  return fullPath;
}

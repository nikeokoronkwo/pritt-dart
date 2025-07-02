import 'dart:typed_data';

import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:pritt_server/src/main/base/storage.dart';
import 'package:pritt_server/src/main/base/storage/interface.dart';
import 'package:pritt_server/src/main/crs/interfaces.dart';
import 'package:test/scaffolding.dart';

@GenerateMocks([CRSArchiveController, PrittStorage])
import 'crs_storage_test.mocks.dart';

void main() {
  group('Pritt Storage Interface Testing', () {});

  group('Pritt Storage Testing', () {
    late final MockPrittStorage storage;
    late final FileSystem storageFS;

    setUpAll(() {
      storage = MockPrittStorage();
      storageFS = MemoryFileSystem.test();

      when(storage.publishingBucket).thenReturn(Bucket(creationDate: DateTime.now(), name: 'pritt-publishing-buckets'));
      when(storage.adapterBucket).thenReturn(Bucket(creationDate: DateTime.now(), name: 'pritt-publishing-buckets'));
      when(storage.publishingBucket).thenReturn(Bucket(creationDate: DateTime.now(), name: 'pritt-publishing-buckets'));

      when(storage.createPackage('pritt', any, any)).thenAnswer((_) async => true);
      when(storage.getPackage('pritt')).thenAnswer((_) async => CRSFileOutputStream(path: 'pritt', data: Uint8List.fromList([]), metadata: {}, size: 0, hash: ''));
      when(storage.getPackage(any)).thenAnswer((invocation) async {
        final file = storageFS.file(p.setExtension(invocation.positionalArguments.first, '.tar.gz'));
        return CRSFileOutputStream(path: file.path, data: await file.readAsBytes(), metadata: {}, size: await file.length(), hash: '');
      });

    });

    tearDownAll(() {});
  });

  group('CRS Archive Controller Testing', () {});
}

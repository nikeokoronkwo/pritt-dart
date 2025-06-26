import 'package:file/file.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pritt_server/src/main/crs/interfaces.dart';
import 'package:pritt_server/src/main/base/storage.dart';
import 'package:test/scaffolding.dart';

@GenerateMocks([CRSArchiveController, PrittStorage])
import 'crs_storage_test.mocks.dart';

void main() {
  group('Pritt Storage Interface Testing', () {});

  group('Pritt Storage Testing', () {
    late final PrittStorage storage;
    late final FileSystem storageFS;

    setUpAll(() {
      storage = MockPrittStorage();
    });

    tearDownAll(() {});
  });

  group('CRS Archive Controller Testing', () {});
}

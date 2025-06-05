import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pritt_server/src/main/adapter/adapter.dart';
import 'package:pritt_server/src/main/adapter/adapter/request_options.dart';
import 'package:pritt_server/src/main/adapter/adapter/resolve.dart';
import 'package:pritt_server/src/main/adapter/adapter/result.dart';
import 'package:pritt_server/src/main/crs/interfaces.dart';
import 'package:pritt_server/src/main/utils/mixins.dart';
import 'package:pritt_server/src/main/utils/user_agent.dart';
import 'package:test/test.dart';

@GenerateMocks([CRSDBController, CRSArchiveController, JsonConvertible])
import 'adapter_test.mocks.dart';

void main() {
  group('Adapter', () {
    late MockCRSDBController mockDBController;
    late MockCRSArchiveController mockArchiveController;
    MockJsonConvertible mockMetaResult = MockJsonConvertible();

    setUp(() {
      mockDBController = MockCRSDBController();
      mockArchiveController = MockCRSArchiveController();
    });

    // TODO: More Tests
    group('Meta Adapter Result', () {
      when(mockMetaResult.toJson()).thenReturn({'name': 1, 'age': 2});

      final adapter = Adapter(
        id: 'test-adapter',
        resolve: (resolveObject) => AdapterResolveType.meta,
        request: (requestObject, controller) async {
          return AdapterMetaResult(mockMetaResult);
        },
        retrieve: (requestObject, controller) async {
          return AdapterArchiveResult(Stream.empty(), 'test.tar.gz');
        },
      );

      test('should handle onRequest', () {
        final resolveObject = AdapterResolveObject(
            uri: Uri.http('example.org', '/api/packages/foo'),
            method: RequestMethod.GET,
            userAgent: UserAgent.fromRaw('Dart test 3.7.0'));
        final result = adapter.resolve(resolveObject);

        expect(result.isResolved, isTrue);
        expect(result, equals(AdapterResolveType.meta));
      });

      test('should resolve correctly using onResolve', () async {
        final resolveObject = AdapterResolveObject(
            uri: Uri.http('example.org', '/api/packages/foo'),
            method: RequestMethod.GET,
            userAgent: UserAgent.fromRaw('Dart test 3.7.0'));
        final result = await adapter.metaRequest(
            AdapterRequestObject(
                resolveObject: resolveObject,
                resolveType: AdapterResolveType.meta),
            mockDBController);

        assert(result is AdapterMetaResult, "adapter should be meta");
        expect((result as AdapterMetaResult).body.toJson(),
            equals({'name': 1, 'age': 2}));
      });
    });
  });
}

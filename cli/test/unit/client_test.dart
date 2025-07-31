import 'package:mockito/mockito.dart';
import '../../../packages/common/lib/interface.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

import '../utils/client.dart';
import '../utils/mocks/packages.dart';

void main() {
  group('Client Testing', () {
    late final MockPrittClient client;

    setUp(() {
      client = MockPrittClient();

      when(
        client.getPackages(),
      ).thenReturn(GetPackagesResponse(packages: createMockPackages()));
    });

    test('Client Usage', () {});
  });
}

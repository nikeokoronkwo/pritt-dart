import 'package:mockito/mockito.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

import '../utils/client.dart';
import 'package:pritt_common/interface.dart';

import '../utils/mocks/packages.dart';

void main(List<String> args) {
  group('Client Testing', () {
    late final MockPrittClient client;

    setUp(() {
      client = MockPrittClient();

      when(client.getPackages())
          .thenReturn(GetPackagesResponse(packages: createMockPackages()));
    });

    test('Client Usage', () {

    });
  });
}

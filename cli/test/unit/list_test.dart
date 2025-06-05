import 'package:mockito/mockito.dart';
import 'package:pritt_cli/src/list.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

import '../utils/client.dart';
import 'package:pritt_common/interface.dart';

import '../utils/mocks/packages.dart';

void main() {
  group('Client List Testing', () {
    late final MockPrittClient client;

    setUp(() {
      client = MockPrittClient();

      when(client.getPackages()).thenReturn(
          GetPackagesResponse(packages: createMockPackages(scoped: true)));
    });

    test('List Packages Usage', () async {
      final pkgs = await client.getPackages();
      final text = listPackageInfo(pkgs.packages ?? []);

      print(text);
    });
  });
}

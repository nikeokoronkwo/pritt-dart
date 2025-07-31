import 'dart:math';

import '../../../../packages/common/lib/interface.dart';

import 'base.dart';

List<Package> createMockPackages({bool scoped = false, int? pkgCount}) {
  final random = Random(DateTime.timestamp().millisecondsSinceEpoch);
  if (!scoped) {
    return (pkgCount == null || pkgCount >= mockNames.length
            ? mockNames
            : mockNames.take(pkgCount))
        .map((n) {
          final authorRecord =
              mockAuthors[random.nextInt(mockAuthors.length - 1)];
          final lang = [null, ...languages][random.nextInt(languages.length)];
          return Package(
            name: n,
            version: List.generate(
              3,
              (i) => i == 0 ? random.nextInt(2) : random.nextInt(9),
            ).join('.'),
            author: Author(name: authorRecord.name, email: authorRecord.email),
            language: lang,
            created_at: DateTime.now().toIso8601String(),
          );
        })
        .toList()
      ..shuffle(random);
  } else {
    return mockScopedNames.map((n) {
      final authorRecord = mockAuthors[random.nextInt(mockAuthors.length - 1)];
      final lang = [null, ...languages][random.nextInt(languages.length)];
      return Package(
        name: '@${n.scope}/${n.$1}',
        version: List.generate(
          3,
          (i) => i == 0 ? random.nextInt(2) : random.nextInt(9),
        ).join('.'),
        author: Author(name: authorRecord.name, email: authorRecord.email),
        language: lang,
        created_at: DateTime.now().toIso8601String(),
      );
    }).toList()..shuffle(random);
  }
}

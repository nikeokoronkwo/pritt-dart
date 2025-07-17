import 'dart:math';

import 'package:pritt_cli/src/utils/typedefs.dart';

import 'base.dart';

List<User> createMockUsers() {
  final now = DateTime.now();
  final random = Random(now.millisecondsSinceEpoch);
  return mockAuthors.map((m) {
    final month = random.nextInt(12);
    final year = month >= now.month
        ? random.nextInt(100) + (now.year - 100) - 1
        : now.year;
    return User(
      name: m.name,
      email: m.email,
      created_at: DateTime.now()
          .copyWith(month: month, year: year)
          .toIso8601String(),
      updated_at: DateTime.now().toIso8601String(),
      packages: [],
    );
  }).toList();
}

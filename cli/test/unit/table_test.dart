import 'dart:math';

import 'package:pritt_cli/src/cli/table.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

final Map<String, List<List<String>>> testData = {
  'basic': [
    ['Name', 'Age', 'City'],
    ['Alice', '30', 'New York'],
    ['Bob', '25', 'London'],
  ],
  'wide': [
    ['Product', 'Description', 'Price'],
    ['Laptop', 'Ultra HD screen with 16GB RAM', '\$1200'],
    ['Mouse', 'Ergonomic wireless mouse', '\$40'],
  ],
};

final Map<String, String> expectedOutputs = {
  'basic': '''
+-------+-----+----------+
| Name  | Age | City     |
+-------+-----+----------+
| Alice | 30  | New York |
| Bob   | 25  | London   |
+-------+-----+----------+''',
  'wide': r'''
+---------+-------------------------------+-------+
| Product | Description                   | Price |
+---------+-------------------------------+-------+
| Laptop  | Ultra HD screen with 16GB RAM | $1200 |
| Mouse   | Ergonomic wireless mouse      | $40   |
+---------+-------------------------------+-------+''',
};

void main() {
  group('Table Testing', () {
    for (final key in testData.keys) {
      test('Render Table Case: $key', () {
        final actual = Table(testData[key]!).write(indentation: Indentation.left).trim();
        final expected = expectedOutputs[key]!.trim();

        expect(actual, equals(expected));
      });
    }
  });
}

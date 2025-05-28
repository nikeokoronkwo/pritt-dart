

import 'package:pritt_cli/src/csv.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

final Map<String, List<Map<String, dynamic>>> csvTestInputs = {
  "simple_case": [
    {"name": "Alice", "age": 30},
    {"name": "Bob", "age": 25}
  ],
  "with_commas": [
    {"product": "Book, Volume 1", "price": 10.5},
    {"product": "Pen", "price": 1.25}
  ],
  "with_quotes": [
    {"quote": 'She said "Hello"', "author": "Alice"},
    {"quote": 'It\'s fine', "author": "Bob"}
  ],
  "boolean_and_dates": [
    {"id": 1, "active": true, "joined": "2023-12-01"},
    {"id": 2, "active": false, "joined": "2024-01-15"}
  ],
  "mixed_types": [
    {"id": 1, "value": null, "note": "First"},
    {"id": 2, "value": 123.456, "note": "Second"}
  ]
};

final Map<String, String> csvExpectedOutputs = {
  "simple_case":
  "name,age\n"
      "Alice,30\n"
      "Bob,25",

  "with_commas":
  "product,price\n"
      "\"Book, Volume 1\",10.5\n"
      "Pen,1.25",

  "with_quotes":
  "quote,author\n"
      "\"She said \"\"Hello\"\"\",Alice\n"
      "It's fine,Bob",

  "boolean_and_dates":
  "id,active,joined\n"
      "1,true,2023-12-01\n"
      "2,false,2024-01-15",

  "mixed_types":
  "id,value,note\n"
      "1,,First\n"
      "2,123.456,Second"
};


void main() {
  group('CSV Encoding Testing', () {
    for (final key in csvTestInputs.keys) {
      test('Test Case: $key', () {
        final actual = csvEncode(csvTestInputs[key]!);
        final expected = csvExpectedOutputs[key];
        
        expect(actual, equals(expected));
      });
    }
  });
}
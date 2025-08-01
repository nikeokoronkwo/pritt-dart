import 'package:pritt_common/config.dart';
import 'package:test/test.dart';

final nameTestInput = {
  'Nikechukwu Okoronkwo': User(name: "Nikechukwu Okoronkwo"),
  'John Doe': User(name: "John Doe"),
  'Jane Lane Smith': User(name: "Jane Lane Smith"),
  'Alice Bob <alice@example.com>': User(
    name: "Alice Bob",
    email: "alice@example.com",
  ),
  'Bob Alice <bobalice@example.com>': User(
    name: "Bob Alice",
    email: "bobalice@example.com",
  ),
  'Charlie Brown <charlie@example.com>': User(
    name: "Charlie Brown",
    email: "charlie@example.com",
  ),
};

void main() {
  group('User name test', () {
    nameTestInput.forEach((input, expectedUser) {
      test('should parse "$input" correctly', () {
        final user = User.parse(input);
        expect(user.name, expectedUser.name);
        expect(user.email, expectedUser.email);
      });
    });
  });
}

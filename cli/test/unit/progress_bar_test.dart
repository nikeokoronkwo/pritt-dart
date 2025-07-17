import 'package:pritt_cli/src/cli/progress_bar.dart';
import 'package:test/test.dart';

class ProgressBarTest {
  int current;
  int total;
  int width;

  ProgressBarTest(this.current, this.total, {required this.width});

  @override
  bool operator ==(Object other) =>
      other is ProgressBarTest &&
      other.current == current &&
      other.total == total &&
      other.width == width;

  @override
  int get hashCode => Object.hash(current, total, width);
}

final progressBarTests = {
  ProgressBarTest(0, 100, width: 10): "[----------] 0%",
  ProgressBarTest(50, 100, width: 10): "[█████-----] 50%",
  ProgressBarTest(100, 100, width: 10): "[██████████] 100%",
  ProgressBarTest(25, 100, width: 20): "[█████---------------] 25%",
  ProgressBarTest(75, 100, width: 20): "[███████████████-----] 75%",
  // Additional cases
  ProgressBarTest(10, 100, width: 10): "[█---------] 10%",
  ProgressBarTest(90, 100, width: 10): "[█████████-] 90%",
  ProgressBarTest(33, 100, width: 10): "[███-------] 33%",
  ProgressBarTest(100, 200, width: 10): "[█████-----] 50%",
  ProgressBarTest(0, 1, width: 5): "[-----] 0%",
  ProgressBarTest(1, 1, width: 5): "[█████] 100%",
};

void main() {
  group('Progress Bar Tests', () {
    progressBarTests.forEach((testObj, expected) {
      test(
        'Progress bar for ${testObj.current}/${testObj.total} with width ${testObj.width}',
        () {
          final result = generateProgressBar(
            testObj.current,
            testObj.total,
            width: testObj.width,
          );
          expect(
            result,
            equals(expected),
            reason: "Expected: $expected, but got: $result",
          );
        },
      );
    });
  });
}

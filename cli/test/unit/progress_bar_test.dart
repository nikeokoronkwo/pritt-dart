import 'package:pritt_cli/src/cli/progress_bar.dart';
import 'package:test/test.dart';

class ProgressBarTest {
  int current;
  int total;
  int width;

  ProgressBarTest(this.current, this.total, {required this.width});
}

final progressBarTests = {
  ProgressBarTest(0, 100, width: 10): "[----------] 0%",
  ProgressBarTest(50, 100, width: 10): "[█████-----] 50%",
  ProgressBarTest(100, 100, width: 10): "[██████████] 100%",
  ProgressBarTest(25, 100, width: 20): "[█████---------------] 25%",
  ProgressBarTest(75, 100, width: 20): "[███████████████-----] 75%",
};

void main() {
  group('Progress Bar Tests', () {
    progressBarTests.forEach((testObj, expected) {
      test(
          'Progress bar for ${testObj.current}/${testObj.total} with width ${testObj.width}',
          () {
        final result = generateProgressBar(testObj.current, testObj.total,
            width: testObj.width);
        expect(result, equals(expected),
            reason: "Expected: $expected, but got: $result");
      });
    });
  });
}

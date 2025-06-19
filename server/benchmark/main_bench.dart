import 'package:benchmark_harness/benchmark_harness.dart';

class ServerBenchmark extends AsyncBenchmarkBase {
  const ServerBenchmark() : super('Server');

  static void main() {
    const ServerBenchmark().report();
  }
}

void main() {
  ServerBenchmark.main();
}
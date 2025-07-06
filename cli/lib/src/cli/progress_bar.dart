import 'dart:io';
import 'dart:math';

/// [widthPadding] refers to any extra padding needed for the width of the progress bar
String generateProgressBar(
  int current,
  int total, {
  int? width,
  int widthPadding = 0,
}) {
  if (total == 0) throw Exception("Total progress cannot be zero");

  final progress = current / total;
  final progressValue = (progress * 100).toInt();

  width ??=
      (stdout.terminalColumns -
      4 -
      widthPadding -
      (progressValue != 0 ? ((log(progressValue) * log10e) + 1) : 1).toInt());
  final int completed = (progress * width).toInt();

  return "[${"█" * completed}${"-" * (width - completed)}] $progressValue%";
}

class ProgressBar {
  String message;
  String? completeMessage;

  ProgressBar(this.message, {this.completeMessage});

  void tick(int current, int total) {
    int messageLength = max(
      message.length,
      (completeMessage ?? message).length,
    );
    stdout.write(
      '${(current == total ? (completeMessage ?? message) : message).padRight(messageLength)} ${generateProgressBar(current, total, widthPadding: messageLength + 2)}\r',
    );
  }

  void end() {
    stdout.writeln();
  }
}

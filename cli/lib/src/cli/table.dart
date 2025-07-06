import 'package:io/ansi.dart';
import '../utils/extensions.dart';

enum Indentation { left, center, right }

/// A table in the terminal, with rows and columns
class Table {
  List<List<String>> array;
  final List<String>? _header;

  List<String> get header => _header ?? array.first;
  List<List<String>> get lines =>
      _header != null ? array : array.skip(1).toList();

  int get rows => array.first.length;
  int get columns => array.length - (_header != null ? 0 : 1);

  Table(this.array, {List<String>? header}) : _header = header;

  String write({
    String sep = '|',
    String headerLine = '=',
    String ifEmpty = '_',
    Indentation indentation = Indentation.center,
  }) {
    StringBuffer sink = StringBuffer();

    final allLines = _header != null ? [...array, _header] : array;

    // index lengths to use as
    final lineSpacings = List.generate(allLines.map((l) => l.length).first, (
      i,
    ) {
      return allLines.map((l) => l[i]);
    }).map((col) => col.map((v) => v.length).max + 2).toList();

    // draw up border
    sink.writeln(
      _writeLine(
        List.filled(rows, ''),
        sep: '+',
        ifEmpty: '-',
        lineSpacings: lineSpacings,
        indentation: indentation,
      ),
    );

    // write header lines
    sink.writeln(
      _writeLine(
        header,
        sep: sep,
        ifEmpty: ifEmpty,
        lineSpacings: lineSpacings,
        indentation: indentation,
        format: (hdr) => styleBold.wrap(hdr)!,
      ),
    );

    // border again
    sink.writeln(
      _writeLine(
        List.filled(rows, ''),
        sep: '+',
        ifEmpty: '-',
        lineSpacings: lineSpacings,
        indentation: indentation,
      ),
    );

    for (final line in lines) {
      sink.writeln(
        _writeLine(
          line,
          sep: sep,
          ifEmpty: ifEmpty,
          lineSpacings: lineSpacings,
          indentation: indentation,
        ),
      );
    }
    // bottom border
    if (lines.isNotEmpty) {
      sink.writeln(
        _writeLine(
          List.filled(rows, ''),
          sep: '+',
          ifEmpty: '-',
          lineSpacings: lineSpacings,
          indentation: indentation,
        ),
      );
    }

    return sink.toString();
  }

  String _writeLine(
    List<String> items, {
    required String sep,
    required String ifEmpty,
    required List<int> lineSpacings,
    Indentation indentation = Indentation.center,
    String Function(String)? format,
  }) {
    final resultList = [];

    for (int i = 0; i < items.length; ++i) {
      final pad = lineSpacings[i];
      final char = items[i];

      // divide the padding
      final sidePad = pad ~/ 2;

      // print(char.isEmpty ? ifEmpty * pad : char.padLeft(char.length + sidePad).padRight(char.length + pad));
      final charOutput = switch (indentation) {
        Indentation.left => ' ${char.padRight(pad - 1)}',
        Indentation.center =>
          char.padLeft((char.length / 2).round() + sidePad).padRight(pad),
        Indentation.right => '${char.padLeft(pad - 1)} ',
      };

      resultList.add(
        char.isEmpty
            ? ifEmpty * pad
            : (format == null ? charOutput : format(charOutput)),
      );
    }

    // left and right
    return sep + resultList.join(sep) + sep;
  }
}

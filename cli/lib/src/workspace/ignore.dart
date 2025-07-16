import 'dart:convert';

import 'package:glob/glob.dart';
import 'package:pritt_common/interface.dart';

class IgnoreMatcher {
  final List<IgnorePattern> patterns;
  final LineSplitter _lineSplitter = const LineSplitter();

  IgnoreMatcher([List<String>? lines])
    : patterns =
          lines
              ?.map((l) => l.trim())
              .where((l) => l.isNotEmpty && !l.startsWith('#'))
              .map((l) => IgnorePattern.from(l))
              .toList() ??
          <IgnorePattern>[];

  void add(String line) {
    if (line.isNotEmpty && !line.startsWith('#')) {
      patterns.add(IgnorePattern.from(line.trim()));
    }
  }

  void addLines(Iterable<String> lines) {
    patterns.addAll(
      lines
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty && !l.startsWith('#'))
          .map((l) => IgnorePattern.from(l)),
    );
  }

  void addContent(String contents) {
    return addLines(_lineSplitter.convert(contents));
  }

  bool ignores(String path) {
    bool ignored = false;
    for (final pat in patterns) {
      if (pat.matches(path)) {
        ignored = !pat.isNegation;
      }
    }
    return ignored;
  }

  factory IgnoreMatcher.from(String contents) {
    return IgnoreMatcher(const LineSplitter().convert(contents));
  }
}

class IgnorePattern {
  final Glob glob;
  final bool isNegation;

  IgnorePattern.from(String pattern)
    : isNegation = pattern.startsWith('!'),
      glob = Glob(
        pattern.startsWith('!') ? pattern.substring(1) : pattern,
        recursive: true,
      );

  bool matches(String path) {
    // Normalize for matching: use forward slashes
    return glob.matches(path);
  }
}

/// Some basic ignored files:
const List<String> commonlyIgnoredFiles = [
  '.*.swp',
  '._*',
  '.DS_Store',
  '.git',
  '.gitignore',
  '.hg',
  '.lock-wscript',
  '.svn',
  'CVS',
  '.wafpickle-*',
];

String? getVCSIgnoreFile(VCS vcs) {
  return switch (vcs) {
    VCS.git => '.gitignore',
    VCS.mercurial => '.hgignore',
    VCS.fossil => '.fossil-settings/ignore-glob',
    _ => null,
  };
}

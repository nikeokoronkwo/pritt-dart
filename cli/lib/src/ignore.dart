import 'package:glob/glob.dart';

/// An ignore file is basically a list of paths to ignore
typedef IgnoreFiles = Iterable<String>;

extension MatchIgnore on IgnoreFiles {
  bool match(String path) {
    return any((ignore) {
      // convert path to glob
      final p = Glob(ignore, caseSensitive: false, recursive: false);
      return p.matches(path);
    });
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

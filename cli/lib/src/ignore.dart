/// An ignore file is basically a list of paths to ignore
typedef IgnoreFiles = Iterable<String>;

extension MatchIgnore on IgnoreFiles {
  bool match(String path) {
    return this.any((ignore) {
      // convert path to glob
      throw UnimplementedError();
    });
  }
}

/// Some basic ignored files:
const List<String> ignoredFiles = [
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
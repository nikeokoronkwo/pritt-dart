
/// Convert a list of [Map] values into a CSV table
String csvEncode(Iterable<Map<String, dynamic>> values) {
  final headers = values.first.keys;
  final items = values.map((v) => v.values.map((val) {
    var out = val;
    // check for commas
    if (val is String) {
      if (val.contains('"')) out = (out as String).replaceAll('"', '""');
      if (val.contains(',') || val.contains('"')) return '"$out"';
    }
    if (val == null) return '';
    return out;
  }));
  return [headers.join(','), ...items.map((i) => i.join(','))].join('\n');
}
import 'package:args/args.dart';

enum OutputFormat {
  text, csv, json
}

OutputFormat getFormatFromResults(ArgResults results) {
  if (results.wasParsed('csv')) return OutputFormat.csv;
  else if (results.wasParsed('json')) return OutputFormat.json;
  else return OutputFormat.text;
}
import 'config.dart';

String generateTailwindMainCssFile(WGTStyle style) {
  StringBuffer buffer = StringBuffer();

  // add tailwindcss line
  buffer.writeln('@import "tailwindcss";');

  // add css code
  buffer.writeAll([
    '@theme {', 
    ...style.colours.primary.map((k, v) => MapEntry(k == -1 ? '--color-primary' : '--color-primary-$k', v)).entries.map((e) => '${e.key}: ${e.value};'),
    ...style.colours.accent.map((k, v) => MapEntry(k == -1 ? '--color-accent' : '--color-accent-$k', v)).entries.map((e) => '${e.key}: ${e.value};'), 
    '--font-main: "${style.font.family}", ${style.font.type.value};', '}'
  ], '\n');

  // return
  return buffer.toString();
}
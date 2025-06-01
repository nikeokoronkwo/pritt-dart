String generateTailwindMainCssFile() {
  StringBuffer buffer = StringBuffer();

  // add tailwindcss line
  buffer.writeln('@import "tailwindcss";');

  // add css code

  // return
  return buffer.toString();
}
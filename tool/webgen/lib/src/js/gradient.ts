import chroma from 'chroma-js';

export function generateTailwindColorScale(baseHex: string) {
  if (!chroma.valid(baseHex)) {
    throw new Error('Invalid hex color');
  }

  // Define light to dark anchors
  const light = chroma(baseHex).brighten(2.5).saturate(1.2).hex();
  const dark = chroma(baseHex).darken(2.5).saturate(1.5).hex();

  const scale = chroma.scale([light, baseHex, dark]).mode('lab').colors(9);

  const steps = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
  const lightest = chroma(baseHex).brighten(3.5).desaturate(1).hex();

  const colors: Record<number, string> = { 50: lightest };

  steps.slice(1).forEach((step, idx) => {
    colors[step] = scale[idx];
  });

  colors[-1] = baseHex;

  return colors;
}

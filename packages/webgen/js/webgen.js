/** The main entrypoint for the Dart code, since Dart cannot handle async via Node */

import { createRequire } from "module";
import * as fs from "node:fs/promises";
import * as path from "node:path";
import Handlebars from "handlebars";

const require = createRequire(import.meta.url);

globalThis.self = globalThis;
globalThis.require = require;
globalThis.fs = fs;
globalThis.path = path;
globalThis.Handlebars = Handlebars;
globalThis.dartMainRunner = async function (main, args) {
  const dartArgs = process.argv.slice(2);
  await main(dartArgs);
};

async function loadMain() {
  require("./webgen_dart.js");
}

if (require.main === require.module) {
  await loadMain();
}

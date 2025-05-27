/** The main entrypoint for the Dart code, since Dart cannot handle async via Node */

import { createRequire } from "node:module";
import * as fs from "node:fs/promises";
import * as path from "node:path";
import Handlebars from "handlebars";
import { z } from "zod"

const require = createRequire(import.meta.url);

globalThis.self = globalThis;
globalThis.require = require;
globalThis.fs = fs;
globalThis.path = path;

// dependencies
globalThis.Handlebars = Handlebars;


// dart main runner
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

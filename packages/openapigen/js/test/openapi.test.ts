import { test } from 'vitest';
import { readdirSync, readFileSync } from 'node:fs';
import { parseOpenAPIDocumentSource } from '../src/main.js';
import { join } from 'node:path';
import { dereference } from '@scalar/openapi-parser';
import { OpenAPIV3 } from '@scalar/openapi-types';

const specDir = "./test/specs";


test("", async () => {
  const dir = readdirSync(specDir, { encoding: "utf8" });
  for (const specFile of dir) {
    const file = readFileSync(join(specDir, specFile), { encoding: "utf8" });
    // console.log(file);
    const { schema } = await dereference(file);
    const spec = schema as OpenAPIV3.Document;

    const exportableSpec = await parseOpenAPIDocumentSource(file);
    console.log(spec.paths);
  }
});

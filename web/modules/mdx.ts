import { createResolver, defineNuxtModule, extendPages } from "@nuxt/kit";
import { readdir } from "node:fs/promises";
import { join, extname, sep } from "node:path";
import createNuxtPath from "~/lib/createNuxtPath";

/** dw I wrote the rest... */
export default defineNuxtModule({
  async setup(options) {
    const { resolve } = createResolver(import.meta.url);

    const pagesDir = resolve("../pages");

    const files = await readdir(pagesDir, {
      encoding: "utf-8",
      recursive: true,
    });

    extendPages((pages) => {
      for (const file of files.filter((f) => extname(f) === ".mdx")) {
        const fullPath = join("../pages", file);
        pages.unshift({
          path: createNuxtPath(file),
          file: resolve(fullPath),
        });
      }
    });
  },
});

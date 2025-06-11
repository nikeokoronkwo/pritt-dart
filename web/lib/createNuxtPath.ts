import * as path from "node:path"

/**
 * Convert a file path in the Nuxt pages directory to a Nuxt route.
 * @param filePath Absolute or relative path like 'pages/blog/[id].vue'
 * @returns Nuxt route path like '/blog/:id'
 */
export default function filePathToNuxtRoute(filePath: string): string {
  const ext = path.extname(filePath);
  const withoutExt = filePath.slice(0, -ext.length);

  const parts = withoutExt.split(path.sep).map((part) => {
    if (part === "index") return ""; // index.vue becomes root
    if (part.startsWith("[[...") && part.endsWith("]]")) return "*";
    if (part.startsWith("[...") && part.endsWith("]")) return "*";
    if (part.startsWith("[") && part.endsWith("]")) {
      const param = part.slice(1, -1);
      return `:${param}`;
    }
    return part;
  });

  const route = "/" + parts.filter(Boolean).join("/");

  return route === "/index" ? "/" : route;
}
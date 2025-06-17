import { defineTransformer } from "@nuxt/content";
import asciidoctor from "asciidoctor";
import createNuxtPath from "../lib/createNuxtPath";
import { relative } from "node:path";

const asciidoc = asciidoctor();

export default defineTransformer({
  name: "asciidoc",
  extensions: [".ad", ".adoc", ".asciidoc"], // File extensions to apply this transformer to
  parse(file, options) {
    const { id, body } = file;

    const doc = asciidoc.load(body, {
      safe: "unsafe",
    });

    // Extract metadata
    const metadata = {
      title: doc.getDocumentTitle(),
      subtitle: doc.getAttribute("subtitle"),

      author: doc.getAuthor(),
      email: doc.getAttribute("email"),
      firstname: doc.getAttribute("firstname"),
      lastname: doc.getAttribute("lastname"),
      authorinitials: doc.getAttribute("authorinitials"),

      revnumber: doc.getAttribute("revnumber"),
      revdate: doc.getAttribute("revdate"),
      description: doc.getAttribute("description"),
      keywords: doc.getAttribute("keywords"),
      updated: new Date(doc.getAttribute("localdate") ?? Date.now()),

      // All attributes at once
      allAttributes: doc.getAttributes(),
    };

    console.log(metadata);

    // Then convert to HTML
    const parsedBody = doc.convert();

    console.log(parsedBody, id, "FEIN", options);

    // Modify the file object as needed
    return {
      ...file,
      body: parsedBody,
      path: createNuxtPath(relative("content", file.path)),
      meta: metadata,
      title: metadata.title,
      seo: {
        ...file.seo,
        title: metadata.title,
        description: metadata.subtitle ?? metadata.description,
      },
    };
  },
});

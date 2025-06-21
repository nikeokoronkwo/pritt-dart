import tailwindcss from "@tailwindcss/vite";
import mdx from "@mdx-js/rollup";

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2025-05-15",
  devtools: { enabled: true },

  modules: [
    "@nuxt/content",
    "@nuxt/eslint",
    "@nuxt/fonts",
    "@nuxt/icon",
    "@nuxt/image",
    "@nuxt/scripts",
    "@nuxt/test-utils",
    "@scalar/nuxt",
    "@nuxtjs/color-mode",
    "@pinia/nuxt",
    'reka-ui/nuxt'
  ],

  css: ["~/assets/css/main.css"],
  vite: {
    plugins: [
      tailwindcss(),
      mdx({
        jsxImportSource: "vue",
      }),
    ],
  },

  runtimeConfig: {
    databaseName: "",
    databaseUsername: "",
    databasePassword: "",
    databaseHost: "",
    databasePort: "",
    public: {
      apiUrl: "",
    },
  },

  icon: {
    mode: "css",
    cssLayer: "base",
  },

  content: {
    build: {
      transformers: ["./transformers/asciidoc"],
    },
  },
});

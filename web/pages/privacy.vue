<script setup lang="ts">
const {
  data: privacyDoc,
  status,
  refresh,
} = await useAsyncData("blog", () =>
  queryCollection("legal").path("/legal/privacy").first(),
);

onMounted(() => {
  console.log(privacyDoc.value);
});
</script>

<template>
  <div class="mx-auto w-full max-w-4xl px-4 py-16 sm:px-6 lg:px-8">
    <div
      v-if="status === 'success'"
      v-html="privacyDoc?.body"
      class="adoc"
    ></div>
  </div>
</template>

<style lang="css">
@reference "~/assets/css/main.css";

.adoc * {
  font-family: "Inter", sans-serif;
  @apply print:mx-0 print:px-0 print:pt-0 print:text-[11pt];
}

.adoc h1,
h2,
h3,
h4,
h5,
h6,
.sect1 > h2 {
  @apply font-sans leading-tight;
}

.adoc h1,
h2 {
  @apply py-2;
}

.adoc h1 {
  @apply mb-8 border-b text-center text-3xl font-bold;
}

.adoc h2 {
  @apply mb-1 text-2xl font-semibold text-slate-800;
}

.adoc h3 {
  @apply text-xl font-semibold;
}

.adoc h4,
h5,
h6 {
  @apply text-lg text-gray-600 capitalize italic;
}

.adoc #toc,
.toc {
  @apply mb-6 rounded border border-gray-300 bg-gray-50 p-4;
}

.adoc #toctitle {
  @apply mb-2 text-lg font-bold;
}

.adoc ul,
ol {
  @apply my-4 list-disc pl-6;
}

.adoc {
  .toc ul {
    @apply list-none space-y-1 pl-0 text-sm;
  }

  .toc ul ul {
    @apply mt-1 ml-2 space-y-0.5 border-l border-gray-200 pl-4;
  }

  .toc li {
    @apply text-gray-700;
  }

  .toc a {
    @apply text-blue-700 hover:underline;
  }
}

.adoc .paragraph {
  @apply py-2;
}

.adoc p {
  @apply py-1;
}

@media print {
  body {
    @apply bg-white text-[11pt] text-black;
  }

  a[href]::after {
    content: " (" attr(href) ")";
    font-size: 0.9em;
  }

  nav,
  .no-print {
    display: none !important;
  }

  .adoc .toc {
    @apply border-black bg-white;
  }

  .adoc .toc a {
    @apply text-black;
  }

  .adoc .toctitle {
    @apply border-black text-base font-bold;
  }
}
</style>

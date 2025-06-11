<script setup lang="ts">
const { data: privacyDoc, status, refresh } = await useAsyncData('blog', () => queryCollection('legal').path('/legal/privacy').first())

onMounted(() => {
    console.log(privacyDoc.value)
})
</script>

<template>
    <div class="w-full max-w-4xl mx-auto py-16 px-4 sm:px-6 lg:px-8">
        <div v-if="status === 'success'" v-html="privacyDoc?.body" class="adoc"></div>
    </div>
</template>

<style lang="css">
@reference "~/assets/css/main.css";

.adoc * {
    font-family: 'Inter', sans-serif;
    @apply print:text-[11pt] print:mx-0 print:px-0 print:pt-0;
}

.adoc h1, h2, h3, h4, h5, h6, .sect1 > h2 {
    @apply font-sans leading-tight;
}

.adoc h1, h2 {
    @apply py-2;
}

.adoc h1 {
    @apply font-bold text-3xl mb-8 text-center border-b
}

.adoc h2 {
    @apply font-semibold text-slate-800 text-2xl mb-1
}

.adoc h3 {
    @apply text-xl font-semibold;
}

.adoc h4, h5, h6 {
    @apply text-lg italic text-gray-600 capitalize;
}

.adoc #toc, .toc {
    @apply border border-gray-300 bg-gray-50 p-4 mb-6 rounded;
}

.adoc #toctitle {
    @apply font-bold text-lg mb-2;
}

.adoc ul, ol {
    @apply pl-6 my-4 list-disc;
}

.adoc {
    .toc ul {
        @apply list-none pl-0 space-y-1 text-sm;
    }

    .toc ul ul {
        @apply pl-4 border-l border-gray-200 ml-2 mt-1 space-y-0.5;
    }

    .toc li {
        @apply text-gray-700;
    }

    .toc a {
        @apply text-blue-700 hover:underline;
    }
}

.adoc .paragraph {
    @apply py-2
}

.adoc p {
    @apply py-1
}

@media print {
  body {
    @apply bg-white text-black text-[11pt];
  }

  a[href]::after {
    content: " (" attr(href) ")";
    font-size: 0.9em;
  }

  nav, .no-print {
    display: none !important;
  }

  .adoc .toc {
    @apply bg-white border-black;
  }

  .adoc .toc a {
    @apply text-black;
  }

  .adoc .toctitle {
    @apply text-base font-bold border-black;
  }
}
</style>
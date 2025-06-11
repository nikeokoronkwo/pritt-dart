<script setup lang="ts">
import type { NuxtError } from "#app";

const props = defineProps({
  error: Object as () => NuxtError,
});
</script>

<template>
  <div
    class="my-auto flex min-h-screen w-full flex-col items-center justify-center bg-gray-50 px-4 py-12"
  >
    <div
      class="max-w-2xl min-w-xl space-y-6 rounded-xl border border-red-100 bg-white p-8 shadow-lg backdrop-blur"
    >
      <!-- Error Header -->
      <div class="flex flex-col items-center justify-center text-center">
        <div class="text-4xl font-extrabold">
          {{ error?.statusCode || 500 }}
          <span v-if="error?.fatal" class="text-red-500">Fatal Error</span>
          <span v-else>Error</span>
        </div>
        <p class="text-lg text-gray-700">
          {{
            (error?.message ?? error?.statusMessage) ||
            "An unexpected error occurred."
          }}
        </p>
      </div>

      <!-- Stack Trace -->
      <DevOnly>
        <div
          class="max-h-96 overflow-auto rounded-md bg-gray-100 p-4 text-left font-mono text-sm text-gray-800"
        >
          <details>
            <summary class="mb-2 font-bold text-accent-400">Stack Trace:</summary>
            <pre class="break-words whitespace-pre-wrap">{{
              error?.stack || "[no stack trace]"
            }}</pre>
          </details>
        </div>

        <div>
          <p v-if="error?.cause" class="mt-1 text-sm text-gray-400">
            Caused By: <code>{{ error?.cause }}</code>
          </p>
        </div>
      </DevOnly>

      <!-- Action Button -->
      <div class="flex justify-center">
        <NuxtLink
          to="/"
          class="text-accent border-accent hover:bg-accent rounded-md border px-4 py-2 text-sm font-medium transition hover:text-white"
        >
          Go back to Home
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

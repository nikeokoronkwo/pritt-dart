<script setup lang="ts">
definePageMeta({
  middleware: "auth",
  layout: "wf",
});

const route = useRoute();
const query = route.query.id as string | undefined;

const loadingState = ref<"loading" | "success" | "error">("loading");
</script>

<template>
  <div class="my-auto flex w-full flex-col items-center justify-center">
    <div
      class="border-primary-50 min-w-xl space-y-4 rounded-xl border bg-gray-50 p-6 backdrop-blur"
    >
      <!-- Header -->
      <div v-if="loadingState === 'loading'"></div>
      <div v-else-if="loadingState === 'error'"></div>
      <div v-else>
        <div></div>

        <div></div>
      </div>
    </div>
  </div>
</template>

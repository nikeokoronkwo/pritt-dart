<template>
  <div class="flex w-full flex-col items-center justify-center">
    <div class="p-10 px-2">
      <div
        class="bg-primary grid w-4xl grid-cols-1 divide-y rounded-t-xl border"
      >
        <div class="min-h-7 text-primary-50">
          <div class="flex items-center justify-start p-2 text-lg" :key="searchQuery">
            <div v-if="searchQuery">Search Results for: {{ searchQuery }}</div>
            <div v-else>Discover Packages</div>
          </div>
        </div>
        <PackageItem
          v-for="pkg in response?.packages"
          :key="pkg.scope + pkg.name"
          v-bind="pkg"
          class="w-full bg-white"
        />
      </div>
    </div>
    <!-- For next page, if any -->
    <div></div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute();

const searchQuery = route.query.q as string | undefined;

const pritt = usePritt()
const { data: response, refresh, error, status } = pritt.getPackages();

// TODO: Handling more queries

</script>

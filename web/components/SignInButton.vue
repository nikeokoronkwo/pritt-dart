<script setup lang="ts">
defineProps<{
  icon: string;
}>();

defineEmits<{
  click: [event: MouseEvent];
}>();
</script>

<template>
  <button
    @click="(e) => $emit('click', e)"
    class="border-primary-50 hover:border-accent flex w-full max-w-md scale-110 flex-row items-center justify-center space-x-2 rounded-xl border py-2 text-center transition duration-200 ease-in hover:font-bold hover:shadow"
  >
    <Icon :name="icon" />
    <div>
      <slot />
    </div>
  </button>
</template>

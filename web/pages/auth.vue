<script setup lang="ts">
definePageMeta({
  middleware: "auth",
  layout: "wf",
});

const route = useRoute();
const query = route.query.id as string | undefined;
const redirect = route.query.redirect as string | undefined;

const loadingState = ref<"loading" | "success" | "error">("loading");
const pin = ref<string[]>([])
const pinError = ref("");
const pinStatus = ref<null | 'success' | 'fail' | 'pending'>(null);
const router = useRouter();

const PIN_LENGTH = 6;

onMounted(() => {
  setTimeout(() => {
    if (!query) {
      loadingState.value = "error";
      return;
    }
    loadingState.value = "success";
  }, 800);
});

function validatePin(value: string[]) {
  const joined = value.join("");
  return /^[a-zA-Z0-9]+$/.test(joined) && joined.length === PIN_LENGTH;
}

function handleComplete(value: string[]) {
  pinStatus.value = 'pending';
  if (validatePin(value)) {
    pinStatus.value = 'success';
    pinError.value = "";
    setTimeout(() => {
      return router.push(redirect ?? "/auth/success");
    }, 1200);
  } else {
    pinStatus.value = 'fail';
    pinError.value = `Invalid pin. Please enter a valid ${PIN_LENGTH}-character alphanumeric pin code.`;
    setTimeout(() => { pinStatus.value = null; pin.value = []; }, 1200);
  }
}

function onSubmit() {
  // fallback for manual submit
  handleComplete(pin.value);
}
</script>

<template>
  <div class="my-auto flex w-full flex-col items-center justify-center">
    <div
      class="border-primary-50 min-w-xl space-y-8 rounded-xl border bg-gray-50 p-8 backdrop-blur shadow-lg"
    >
      <!-- Header -->
      <div v-if="loadingState === 'loading'">
        <div class="flex flex-col items-center space-y-2">
          <span class="text-lg font-semibold text-primary-400">Loading authentication...</span>
          <div class="h-4 w-4 animate-spin rounded-full border-2 border-accent-400 border-t-transparent"></div>
        </div>
      </div>
      <div v-else-if="loadingState === 'error'">
        <div class="text-red-600">Failed to load authentication data.</div>
      </div>
      <div v-else>
        <div class="mb-4 text-center text-2xl font-bold text-primary-500">Enter your Pin Code</div>
        <form @submit.prevent="onSubmit" class="flex flex-col items-center space-y-6">
          <Label for="pin-input" class="Text">Pin Input</Label>
          <PinInputRoot
            id="pin-input"
            v-model="pin"
            class="flex gap-6 items-center mt-1"
            @complete="handleComplete"
          >
            <PinInputInput 
              v-for="(id, index) in PIN_LENGTH"
              :key="id"
              :index="index"
              placeholder="○"
              class="w-15 h-15 bg-white rounded-lg text-center shadow-sm border border-primary-50 placeholder:text-primary-100 focus:shadow-[0_0_0_2px] focus:shadow-primary-800 outline-none"
            />
          </PinInputRoot>
          <div v-if="pinStatus === 'success'" class="text-green-600 font-semibold text-lg flex items-center gap-2">
            <span>Pin accepted! Redirecting...</span>
          </div>
          <div v-else-if="pinStatus === 'fail'" class="text-red-600 font-semibold text-lg flex items-center gap-2">
            <span>Invalid pin!</span>
          </div>
          <div v-else-if="pinStatus === 'pending'" class="text-yellow-600 font-semibold text-lg flex items-center gap-2">
            <span>Processing...</span>
          </div>
          <div v-if="pinError" class="text-sm text-red-500">{{ pinError }}</div>
        </form>
      </div>
    </div>
  </div>
</template>

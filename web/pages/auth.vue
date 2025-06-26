<script setup lang="ts">
definePageMeta({
  middleware: "auth",
  layout: "wf",
});

const route = useRoute();
const query = route.query.id as string | undefined;
const redirect = route.query.redirect as string | undefined;
const pritt = usePritt();

const loadingState = ref<"loading" | "success" | "error">("loading");
const pin = ref<string[]>([]);

const pinError = ref("");
const pinStatus = ref<null | "success" | "fail" | "pending">(null);
const router = useRouter();

const {
  data: authDetails,
  status: authDetailsStatus,
  error,
  refresh,
} = pritt.getAuthDetailsById(query ?? "");

const targetPin = ref(authDetails.value?.code);
const PIN_LENGTH = ref(targetPin.value?.length ?? 6);

const { data: session } = await authClient.getSession();

onMounted(() => {
  if (!query) {
    loadingState.value = "error";
    return;
  }

  loadingState.value = "success";

  console.log(session);
});

function validatePin(value: string[], target: string) {
  const joined = value.join("");
  return targetPin.value === joined;
}

async function handleComplete(value: string[], target: string) {
  pinStatus.value = "pending";
  if (validatePin(value, target)) {
    pinStatus.value = "success";
    pinError.value = "";
    // resolve
    const response = await pritt.validateAuth({
      user_id: authDetails.value?.user_id ?? session?.user.user_id,
      session_id: authDetails.value?.token,
      time: new Date(Date.now()).toISOString(),
      status: "success",
    });

    return router.push(redirect ?? "/home");
  } else {
    pinStatus.value = "fail";
    pinError.value = `Invalid pin. Please try again`;
    setTimeout(() => {
      pinStatus.value = null;
      pin.value = [];
    }, 1200);
  }
}

function onSubmit(target: string) {
  // fallback for manual submit
  handleComplete(pin.value, target);
}
</script>

<template>
  <div class="my-auto flex w-full flex-col items-center justify-center">
    <div
      class="border-primary-50 min-w-xl space-y-8 rounded-xl border bg-gray-50 p-8 shadow-lg backdrop-blur"
    >
      <!-- Header -->
      <div
        v-if="
          loadingState === 'loading' ||
          authDetailsStatus === 'pending' ||
          authDetails == null
        "
      >
        <div class="flex flex-col items-center space-y-2">
          <span class="text-primary-400 text-lg font-semibold"
            >Loading authentication...</span
          >
          <div
            class="border-accent-400 h-4 w-4 animate-spin rounded-full border-2 border-t-transparent"
          ></div>
        </div>
      </div>
      <div
        v-else-if="loadingState === 'error' || authDetailsStatus === 'error'"
      >
        <div class="text-red-600">Failed to load authentication data.</div>
        <div class="text-sm">
          {{ error }}
        </div>
        <DevOnly>
          <button
            @click="refresh()"
            class="rounded-lg border p-2 transition delay-200 ease-in-out hover:shadow-xl"
          >
            Refresh Request
          </button>
        </DevOnly>
      </div>
      <div v-else>
        <div class="text-primary-500 mb-4 text-center text-2xl font-bold">
          Enter your Pin Code
        </div>
        <form
          @submit.prevent="(e) => onSubmit('')"
          class="flex flex-col items-center space-y-6"
        >
          <Label for="pin-input" class="Text">Pin Input</Label>
          <PinInputRoot
            id="pin-input"
            v-model="pin"
            class="mt-1 flex items-center gap-6"
            @complete="(value) => handleComplete(value, targetPin ?? '')"
          >
            <PinInputInput
              v-for="(id, index) in PIN_LENGTH"
              :key="id"
              :index="index"
              placeholder="○"
              class="border-primary-50 placeholder:text-primary-100 focus:shadow-primary-800 h-15 w-15 rounded-lg border bg-white text-center shadow-sm outline-none focus:shadow-[0_0_0_2px]"
            />
          </PinInputRoot>
          <div
            v-if="pinStatus === 'success'"
            class="flex items-center gap-2 text-lg font-semibold text-green-600"
          >
            <span>Pin accepted! Redirecting...</span>
          </div>
          <div
            v-else-if="pinStatus === 'fail'"
            class="flex items-center gap-2 text-lg font-semibold text-red-600"
          >
            <span>Invalid pin!</span>
          </div>
          <div
            v-else-if="pinStatus === 'pending'"
            class="flex items-center gap-2 text-lg font-semibold text-yellow-600"
          >
            <span>Processing...</span>
          </div>
          <div v-if="pinError" class="text-sm text-red-500">{{ pinError }}</div>
        </form>
      </div>
    </div>
  </div>
</template>

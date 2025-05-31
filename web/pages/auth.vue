<script setup lang="ts">
/**
Auth platform set up
- check if user is signed up
- if user has current session, then confirm authorization
- if user is not logged in, then log user in
- when done, send request to server to complete auth workflow
*/
definePageMeta({
    middleware: 'auth'
})

const route = useRoute();

const session = authClient.useSession()

const state = ref<'pending' | 'error' | 'success'>('pending');
const error = ref<string | null>(null);
const errorMessage = ref<string | null>(null);

onMounted(() => {
    // check the query hash
    const query = route.query.id;
    if (!query) {
        state.value = 'error';
        error.value = 'Unknown Session'
        errorMessage.value = 'Unknown session, redirecting soon'
        setTimeout(() => {
            return navigateTo('/')
        }, 2500);
    }

    // validate user if logged in
});
</script>

<template>
    <div>
        <!-- Auth Platform -->
        <div>
            <!-- Validate if the user is authenticating to the Pritt CLI? -->
            <div v-if="state === 'pending'">

            </div>
            <div v-else-if="state === 'error'">

            </div>
            <div v-else>

            </div>
        </div>
    </div>
</template>
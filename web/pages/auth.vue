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
const query = route.query.id;

const session = authClient.useSession()

const loadingState = ref<'pending' | 'error' | 'success'>('pending');
const loadingError = ref<string | null>(null);
const loadingErrorMessage = ref<string | null>(null);

const { data: details, status, error: detailsError } = usePrittFetch(`/api/auth/details/${query}`, {
    method: 'GET'
})

const pinInput = '';

onMounted(() => {
    // check the query hash
    if (!query) {
        loadingState.value = 'error';
        loadingError.value = 'Unknown Session'
        loadingErrorMessage.value = 'Unknown session, redirecting soon'
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
            <div v-if="loadingState === 'pending'">
                <!-- Pending Loading -->
                <!-- Just Have a Loading Spinner Here -->
            </div>
            <div v-else-if="loadingState === 'error' || loadingError">
                <!-- Error Message -->
                <div>
                    <div>
                        <span>Error</span>
                    </div>
                    <div>
                        <span>{{ loadingErrorMessage ?? "An Unknown Error Occured" }}</span>
                    </div>
                </div>
            </div>
            <div v-else>
                <!-- Success -->

                <div v-if="status === 'pending'">
                    <!-- Loading -->
                    <!-- Text to differentiate this and an actual loading experience -->
                    <div>
                        <!-- Loading Spinner -->
                        <div></div>

                        <!-- Text -->
                        <div>
                            <span>Loading Auth Session</span>
                        </div>
                    </div>
                </div>
                <div v-else-if="status === 'error'">
                    <!-- Error -->
                    <div>
                        <div>
                            <span>Oh No!</span>
                        </div>
                        <div>
                            <span>The Auth Session Did Not Successfully Load</span>
                            <div>
                                {{ detailsError }}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
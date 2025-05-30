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


</script>

<template>
    <div>
        <!-- Auth Platform -->
        <div>
            <!-- Validate if the user is authenticating to the Pritt CLI? -->
            <div></div>
        </div>
    </div>
</template>
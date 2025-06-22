export default defineNuxtRouteMiddleware(async (to, from) => {
  // TODO: We would want to set a timeout to wait for a while before this
  const { data: session } = await authClient.useSession(useFetch);
  if (!session.value) {
    // navigate
    return navigateTo({
      path: "/login",
      query: {
        redirect: to.fullPath
      }
    });
  }
});

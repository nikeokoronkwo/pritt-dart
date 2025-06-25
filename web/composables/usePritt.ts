import type { components } from "~/shared/utils/schema";

/**
 * Define a composable for wrapping {@link usePrittFetch} for making type-safe calls to and from the pritt server
 */
export default function () {
  const config = useRuntimeConfig();

  const apiUrl =
    config.public.apiUrl.split("").length === 0
      ? (() => {
          const url = config.app.baseURL;
          const uri = new URL(url.startsWith("http") ? url : "https://" + url);
          const parts = uri.hostname.split(".");

          // Replace first subdomain or insert 'api' if none
          if (parts[0] === "api") {
            // already has api
          } else {
            parts[0] = "api";
          }

          uri.hostname = parts.join(".");
          return uri.toString();
        })()
      : config.public.apiUrl;

  function getPackages() {
    return usePrittFetch<components["schemas"]["GetPackagesResponse"]>(
      "/api/packages",
      {
        lazy: true,
      },
    );
  }

  function getPublishingStatus(id: string) {
    return usePrittFetch<components["schemas"]["PublishPackageStatusResponse"]>(
      "/api/publish/status",
      {
        query: {
          id,
        },
      },
    );
  }

  function getAuthDetailsById(id: string) {
    return usePrittFetch<components["schemas"]["AuthDetailsResponse"]>(
      `/api/auth/details/${id}`,
    );
  }

  function validateAuth(body: components["schemas"]["AuthValidateRequest"]) {
    return $api(apiUrl)("/api/auth/validate", {
      method: "POST",
      body,
    });
  }

  return {
    getPackages,
    getPublishingStatus,
    getAuthDetailsById,
    validateAuth,
  };
}

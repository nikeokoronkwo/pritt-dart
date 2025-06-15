import type { components } from "~/shared/utils/schema";

/**
 * Define a composable for wrapping {@link usePrittFetch} for making type-safe calls to and from the pritt server
 */
export default function () {
  function getPackages() {
    return usePrittFetch<components["schemas"]["GetPackagesResponse"]>(
      "/api/packages",
      {
        lazy: true,
      },
    );
  }

  return {
    getPackages,
  };
}

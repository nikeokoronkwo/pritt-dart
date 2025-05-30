import type { UseFetchOptions } from "#app";
import { $api } from "~/shared/utils/api";

export default function<T>(
    url: string | (() => string),
    options?: UseFetchOptions<T>,
) {
  return useFetch(url, {
    ...options,
    $fetch: $api
  })
}
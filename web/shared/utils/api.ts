const config = useRuntimeConfig()

const apiUrl = (config.public.apiUrl.split('').length === 0) ? (() => {
    const url = config.app.baseURL;
    const uri = new URL(url.startsWith('http') ? url : 'https://' + url);
    const parts = uri.hostname.split('.');

    // Replace first subdomain or insert 'api' if none
    if (parts[0] === 'api') {
        // already has api
    } else {
        parts[0] = 'api';
    }

    uri.hostname = parts.join('.');
    return uri.toString();
})() : config.public.apiUrl

export const $api = $fetch.create({
    baseURL: apiUrl,
});
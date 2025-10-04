export function getBackendBaseURL() {
  const config = useRuntimeConfig()
  const env = (config.public.apiEnvironment || 'dev').toLowerCase()
  const base = env === 'prod' && config.public.apiBaseUrlProd
    ? (config.public.apiBaseUrlProd as string)
    : (config.public.apiBaseUrlDev as string)
  return base.replace(/\/?$/, '')
}

function joinUrl(base: string, path: string) {
  const b = base.replace(/\/+$/, '')
  const p = path.replace(/^\/+/, '')
  return `${b}/${p}`
}

export async function proxyBackend<T>(path: string, init?: RequestInit) {
  const base = getBackendBaseURL()
  const url = joinUrl(base, path)
  return await $fetch<T>(url, init as any)
}

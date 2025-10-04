export function getBackendBaseURL() {
  const config = useRuntimeConfig()
  const env = config.public.apiEnvironment || 'dev'
  // For server-side, use container DNS names; for client, use public runtime config (host-mapped)
  const isServer = typeof import.meta !== 'undefined' && (import.meta as any).server
  if (isServer) {
    return env === 'dev' ? 'http://backend:8080' : 'http://backend-prod:8080'
  }
  return env === 'dev' ? (config.public.apiBaseUrlDev as string) : (config.public.apiBaseUrlProd as string)
}

function joinUrl(base: string, path: string) {
  const b = base.replace(/\/+$/, '')
  const p = path.replace(/^\/+/, '')
  return `${b}/${p}`
}

export async function proxyBackend<T>(path: string, init?: RequestInit) : Promise<T> {
  const base = getBackendBaseURL()
  const url = joinUrl(base, path)
  // Nuxt injects $fetch globally server & client
  const fetcher: any = (globalThis as any).$fetch || (globalThis as any).fetch
  const res = await fetcher(url, init as any)
  return res as T
}

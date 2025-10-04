export function getBackendBaseURL() {
  const config = useRuntimeConfig()
  if ('dev' === config.public.apiEnvironment) {
    return 'http://localhost:8080'
  } else {
    return 'http://186.201.152.216'
  }
}

function joinUrl(base: string, path: string) {
  const b = base.replace(/\/+$/, '')
  const p = path.replace(/^\/+/, '')
  return `${b}/${p}`
}

export async function proxyBackend<T>(path: string, init?: RequestInit) : Promise<T> {
  const base = getBackendBaseURL()
  const url = joinUrl(base, path)
  const res = await $fetch<T>(url, init as any) as any
  return res
}

import { computed } from 'vue'
import { useRuntimeConfig, useFetch } from '#app'
import { createError } from 'h3'

// Backend DTOs as returned by the PHP Router
// See backend routes in `packages/backend/src/Router.php`
export interface ArtistDto {
  ArtistId: number
  Name: string | null
}

export interface AlbumDto {
  AlbumId: number
  Title: string | null
  ArtistId: number | null
  Artist: ArtistDto | null
}

export interface GenreDto {
  GenreId: number
  Name: string | null
}

function getApiBaseUrl(environment: string) {
  if ('dev' === environment) {
    return 'http://localhost:8080'
  } else {
    return 'http://186.201.152.216'
  }
}

export const useApi = () => {
  const config = useRuntimeConfig()
  const baseURL = getApiBaseUrl(config.public.apiEnvironment || 'dev')

  async function get<T = unknown>(path: string) {
    const isInternal = path.startsWith('/api')
    const opts: any = { key: path }
    if (!isInternal) {
      opts.baseURL = baseURL
    }
    const { data, error } = await useFetch<T>(path, opts)
    if (error.value) throw createError({ statusCode: 500, statusMessage: error.value.message })
    return data.value as T
  }

  // Helper for backend responses shaped as: { data: T }
  async function getData<T = unknown>(path: string) {
    const res = await get<unknown>(path)
    if (res && typeof res === 'object' && Object.prototype.hasOwnProperty.call(res, 'data')) {
      return (res as { data: T }).data
    }
    return res as T
  }

  return { baseURL, get, getData }
}

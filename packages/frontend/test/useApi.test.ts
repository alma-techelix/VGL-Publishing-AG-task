import { describe, it, expect, vi, beforeEach } from 'vitest'

// Mocks for Nuxt's #app and h3 utilities
const useFetchMock = vi.fn()
const useRuntimeConfigMock = vi.fn()

vi.mock('#app', () => ({
  useFetch: (...args: any[]) => useFetchMock(...args),
  useRuntimeConfig: () => useRuntimeConfigMock(),
}))

vi.mock('h3', () => ({
  createError: ({ statusMessage }: { statusCode: number; statusMessage: string }) => new Error(statusMessage),
}))

// Import after mocks so the composable picks them up
import { useApi } from '../app/composables/useApi'

describe('useApi', () => {
  beforeEach(() => {
    useFetchMock.mockReset()
    useRuntimeConfigMock.mockReset()
  })

  it('sets baseURL based on runtime config (dev)', () => {
    useRuntimeConfigMock.mockReturnValue({ public: { apiEnvironment: 'dev' } })
    const api = useApi()
    expect(api.baseURL).toBe('http://localhost:8080')
  })

  it('sets baseURL based on runtime config (prod)', () => {
    useRuntimeConfigMock.mockReturnValue({ public: { apiEnvironment: 'prod' } })
    const api = useApi()
    expect(api.baseURL).toBe('http://186.201.152.216')
  })

  it('calls useFetch without baseURL for internal /api paths', async () => {
    useRuntimeConfigMock.mockReturnValue({ public: { apiEnvironment: 'dev' } })
    useFetchMock.mockResolvedValue({ data: { value: { ok: true } }, error: { value: null } })

    const api = useApi()
    const res = await api.get('/api/ping')

    expect(res).toEqual({ ok: true })
    expect(useFetchMock).toHaveBeenCalledTimes(1)
    const [path, opts] = useFetchMock.mock.calls[0]
    expect(path).toBe('/api/ping')
    expect(opts).toMatchObject({ key: '/api/ping' })
    expect('baseURL' in opts).toBe(false)
  })

  it('calls useFetch with baseURL for external paths', async () => {
    useRuntimeConfigMock.mockReturnValue({ public: { apiEnvironment: 'prod' } })
    useFetchMock.mockResolvedValue({ data: { value: [1, 2, 3] }, error: { value: null } })

    const api = useApi()
    const res = await api.get('/genres')

    expect(res).toEqual([1, 2, 3])
    expect(useFetchMock).toHaveBeenCalledTimes(1)
    const [path, opts] = useFetchMock.mock.calls[0]
    expect(path).toBe('/genres')
    expect(opts).toMatchObject({ key: '/genres', baseURL: api.baseURL })
  })

  it('throws createError when useFetch returns an error', async () => {
    useRuntimeConfigMock.mockReturnValue({ public: { apiEnvironment: 'dev' } })
    useFetchMock.mockResolvedValue({ data: { value: null }, error: { value: { message: 'boom' } } })

    const api = useApi()
    await expect(api.get('/fail')).rejects.toThrowError('boom')
  })

  it('getData unwraps { data: T } shape', async () => {
    useRuntimeConfigMock.mockReturnValue({ public: { apiEnvironment: 'dev' } })
    useFetchMock.mockResolvedValue({ data: { value: { data: { id: 1 } } }, error: { value: null } })

    const api = useApi()
    const data = await api.getData('/anything')
    expect(data).toEqual({ id: 1 })
  })

  it('getData passes through non-wrapped payloads', async () => {
    useRuntimeConfigMock.mockReturnValue({ public: { apiEnvironment: 'dev' } })
    useFetchMock.mockResolvedValue({ data: { value: { id: 2 } }, error: { value: null } })

    const api = useApi()
    const data = await api.getData('/anything')
    expect(data).toEqual({ id: 2 })
  })
})

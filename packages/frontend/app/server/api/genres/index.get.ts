import { proxyBackend } from '../../utils/backend'
import type { GenreDto } from '~/composables/useApi'

export default defineEventHandler(async () => {
  return await proxyBackend<{ data: GenreDto[] }>('/genres')
})

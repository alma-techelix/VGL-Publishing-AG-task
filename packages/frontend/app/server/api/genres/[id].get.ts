import { proxyBackend } from '../../utils/backend'
import type { GenreDto } from '~/composables/useApi'

export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  return await proxyBackend<{ data: GenreDto }>(`/genres/${id}`)
})

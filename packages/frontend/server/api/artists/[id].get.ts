import { proxyBackend } from '../../utils/backend'
import type { ArtistDto } from '~/composables/useApi'

export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  return await proxyBackend<{ data: ArtistDto }>(`/artists/${id}`)
})

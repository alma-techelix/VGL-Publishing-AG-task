import { proxyBackend } from '../../utils/backend'
import type { AlbumDto } from '~/composables/useApi'

export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  return await proxyBackend<{ data: AlbumDto }>(`/albums/${id}`)
})

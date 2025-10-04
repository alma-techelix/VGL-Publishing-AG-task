import { proxyBackend } from '../../utils/backend'
import type { AlbumDto } from '~/composables/useApi'

export default defineEventHandler(async () => {
  return await proxyBackend<{ data: AlbumDto[] }>('/albums')
})

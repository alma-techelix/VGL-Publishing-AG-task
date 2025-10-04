import { proxyBackend } from '../../utils/backend'
import type { ArtistDto } from '~/composables/useApi'

export default defineEventHandler(async () => {
  return await proxyBackend<{ data: ArtistDto[] }>('/artists')
})

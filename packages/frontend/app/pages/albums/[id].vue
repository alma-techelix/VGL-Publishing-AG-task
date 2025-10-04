<script setup lang="ts">
import type { AlbumDto } from '~/composables/useApi'
const route = useRoute()
const id = computed(() => Number(route.params.id))
const { getData } = useApi()
const { data: album, pending, error } = await useAsyncData(
  () => `album-${id.value}`,
  () => getData<AlbumDto>(`/api/albums/${id.value}`),
  { watch: [id] }
)
</script>

<template>
  <main class="p-6 max-w-3xl mx-auto">
    <header class="mb-6">
      <NuxtLink to="/albums" class="text-sm text-blue-600 hover:underline">← Back to Albums</NuxtLink>
      <h1 class="text-3xl font-bold mt-2">Album</h1>
    </header>

    <div v-if="pending">Loading…</div>
    <div v-else-if="error">Failed to load album.</div>
    <div v-else-if="album" class="space-y-1">
      <h2 class="text-2xl font-semibold">{{ album.Title || '—' }}</h2>
      <p class="text-sm">ID: {{ album.AlbumId }}</p>
      <p class="text-sm opacity-70">
        Artist:
        <template v-if="album.Artist">
          <template v-if="album.Artist.ArtistId">
            <NuxtLink :to="`/artists/${album.Artist.ArtistId}`" class="text-blue-600 hover:underline">
              {{ album.Artist.Name || '—' }}
            </NuxtLink>
          </template>
          <template v-else>
            {{ album.Artist.Name || '—' }}
          </template>
        </template>
        <template v-else>
          —
        </template>
      </p>
    </div>
  </main>
</template>

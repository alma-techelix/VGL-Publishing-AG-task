<script setup lang="ts">
import type { ArtistDto } from '~/composables/useApi'
const route = useRoute()
const id = computed(() => Number(route.params.id))
const { getData } = useApi()
const { data: artist, pending, error } = await useAsyncData(
  () => `artist-${id.value}`,
  () => getData<ArtistDto>(`/api/artists/${id.value}`),
  { watch: [id] }
)
</script>

<template>
  <main class="p-6 max-w-3xl mx-auto">
    <header class="mb-6">
      <NuxtLink to="/artists" class="text-sm text-blue-600 hover:underline">← Back to Artists</NuxtLink>
      <h1 class="text-3xl font-bold mt-2">Artist</h1>
    </header>

    <div v-if="pending">Loading…</div>
    <div v-else-if="error">Failed to load artist.</div>
    <div v-else-if="artist" class="space-y-1">
      <h2 class="text-2xl font-semibold">{{ artist.Name || '—' }}</h2>
      <p class="text-sm opacity-70">ID: {{ artist.ArtistId }}</p>
    </div>
  </main>
</template>

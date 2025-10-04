<script setup lang="ts">
import type { AlbumDto } from '~/composables/useApi'
const { getData } = useApi()
const { data: albums, pending, error } = await useAsyncData('albums', () => getData<AlbumDto[]>('/api/albums'))
</script>

<template>
  <main class="p-6 max-w-3xl mx-auto">
    <header class="mb-4">
      <NuxtLink to="/" class="text-sm text-blue-600 hover:underline">← Home</NuxtLink>
      <h1 class="text-3xl font-bold mt-2">Albums</h1>
    </header>

    <EntityNav />

    <div v-if="pending">Loading…</div>
    <div v-else-if="error">Failed to load albums.</div>
    <ul v-else class="space-y-2">
      <li v-for="al in albums" :key="al.AlbumId" class="p-3 rounded border hover:bg-gray-50">
        <NuxtLink :to="`/albums/${al.AlbumId}`" class="text-blue-600 hover:underline">
          {{ al.Title || '—' }}
        </NuxtLink>
        <p class="text-sm opacity-70" v-if="al.Artist">
          Artist:
          <template v-if="al.Artist.ArtistId">
            <NuxtLink :to="`/artists/${al.Artist.ArtistId}`" class="text-blue-600 hover:underline">
              {{ al.Artist.Name || '—' }}
            </NuxtLink>
          </template>
          <template v-else>
            {{ al.Artist.Name || '—' }}
          </template>
        </p>
      </li>
    </ul>
  </main>
</template>

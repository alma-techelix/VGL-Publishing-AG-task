<script setup lang="ts">
import type { ArtistDto } from '~/composables/useApi'
const { getData } = useApi()
const { data: artists, pending, error } = await useAsyncData('artists', () => getData<ArtistDto[]>('/api/artists'))
</script>

<template>
  <main class="p-6 max-w-3xl mx-auto">
    <header class="mb-4">
      <NuxtLink to="/" class="text-sm text-blue-600 hover:underline">← Home</NuxtLink>
      <h1 class="text-3xl font-bold mt-2">Artists</h1>
    </header>

    <EntityNav />

    <div v-if="pending">Loading…</div>
    <div v-else-if="error">Failed to load artists.</div>
    <ul v-else class="space-y-2">
      <li v-for="a in artists" :key="a.ArtistId" class="p-3 rounded border hover:bg-gray-50">
        <NuxtLink :to="`/artists/${a.ArtistId}`" class="text-blue-600 hover:underline">
          {{ a.Name || '—' }}
        </NuxtLink>
      </li>
    </ul>
  </main>
</template>

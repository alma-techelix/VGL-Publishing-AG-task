<script setup lang="ts">
import type { GenreDto } from '~/composables/useApi'
const { getData } = useApi()
const { data: genres, pending, error } = await useAsyncData('genres', () => getData<GenreDto[]>('/api/genres'))
</script>

<template>
  <main class="p-6 max-w-3xl mx-auto">
    <header class="mb-4">
      <NuxtLink to="/" class="text-sm text-blue-600 hover:underline">← Home</NuxtLink>
      <h1 class="text-3xl font-bold mt-2">Genres</h1>
    </header>

    <EntityNav />

    <div v-if="pending">Loading…</div>
    <div v-else-if="error">Failed to load genres.</div>
    <ul v-else class="space-y-2">
      <li v-for="g in genres" :key="g.GenreId" class="p-3 rounded border hover:bg-gray-50">
        <NuxtLink :to="`/genres/${g.GenreId}`" class="text-blue-600 hover:underline">
          {{ g.Name || '—' }}
        </NuxtLink>
      </li>
    </ul>
  </main>
</template>

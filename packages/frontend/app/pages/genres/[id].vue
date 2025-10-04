<script setup lang="ts">
import type { GenreDto } from '~/composables/useApi'
const route = useRoute()
const id = computed(() => Number(route.params.id))
const { getData } = useApi()
const { data: genre, pending, error } = await useAsyncData(
  () => `genre-${id.value}`,
  () => getData<GenreDto>(`/api/genres/${id.value}`),
  { watch: [id] }
)
</script>

<template>
  <main class="p-6 max-w-3xl mx-auto">
    <header class="mb-6">
      <NuxtLink to="/genres" class="text-sm text-blue-600 hover:underline">← Back to Genres</NuxtLink>
      <h1 class="text-3xl font-bold mt-2">Genre</h1>
    </header>

    <div v-if="pending">Loading…</div>
    <div v-else-if="error">Failed to load genre.</div>
    <div v-else-if="genre" class="space-y-1">
      <h2 class="text-2xl font-semibold">{{ genre.Name || '—' }}</h2>
      <p class="text-sm opacity-70">ID: {{ genre.GenreId }}</p>
    </div>
  </main>
</template>

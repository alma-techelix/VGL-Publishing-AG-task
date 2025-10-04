<script setup lang="ts">
const { baseURL } = useApi()
</script>

<template>
  <main class="p-6 max-w-3xl mx-auto">
    <header class="mb-6">
      <h1 class="text-3xl font-bold">
        Chinook Explorer
      </h1>
    </header>

    <EntityNav />

    <section class="space-y-2">
      <p>Browse data from the backend:</p>
      <ul class="list-disc pl-6">
        <li>
          <NuxtLink to="/artists" class="text-blue-600 hover:underline">
            Artists
          </NuxtLink>
        </li>
        <li>
          <NuxtLink to="/albums" class="text-blue-600 hover:underline">
            Albums
          </NuxtLink>
        </li>
        <li>
          <NuxtLink to="/genres" class="text-blue-600 hover:underline">
            Genres
          </NuxtLink>
        </li>
      </ul>
    </section>
  </main>
</template>

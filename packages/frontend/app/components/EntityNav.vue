<script setup lang="ts">
// Simple navigation between entity sections
</script>

<template>
  <nav class="mb-6 flex gap-4 text-blue-600">
    <NuxtLink to="/artists" class="hover:underline">
      Artists
    </NuxtLink>
    <NuxtLink to="/albums" class="hover:underline">
      Albums
    </NuxtLink>
    <NuxtLink to="/genres" class="hover:underline">
      Genres
    </NuxtLink>
  </nav>
</template>

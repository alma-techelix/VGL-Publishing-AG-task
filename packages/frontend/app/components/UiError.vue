<script setup lang="ts">
const props = defineProps<{ message?: string }>()
const emit = defineEmits<{ (e: 'retry'): void }>()
</script>

<template>
  <div role="alert" class="alert alert-error shadow">
    <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
    <div>
      <h3 class="font-bold">Something went wrong</h3>
      <div class="text-xs">{{ props.message || 'Please try again.' }}</div>
    </div>
    <button class="btn btn-sm ml-auto" @click="emit('retry')">Retry</button>
  </div>
</template>

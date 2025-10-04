// https://nuxt.com/docs/api/configuration/nuxt-config
import tailwindcss from '@tailwindcss/vite'

export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  runtimeConfig: {
    public: {
      apiEnvironment: 'dev',
    },
  },
  vite: {
    plugins: [tailwindcss()],
  },
  css: ['./assets/main.css'],
})

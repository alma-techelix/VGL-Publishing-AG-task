// https://nuxt.com/docs/api/configuration/nuxt-config
import tailwindcss from '@tailwindcss/vite'

export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  runtimeConfig: {
    public: {
      apiEnvironment: process.env.NUXT_PUBLIC_API_ENVIRONMENT || 'dev',
      // Public (browser) endpoints resolve on the host machine
      apiBaseUrlDev: process.env.NUXT_PUBLIC_API_BASE_URL_DEV || 'http://localhost:8080',
      apiBaseUrlProd: process.env.NUXT_PUBLIC_API_BASE_URL_PROD || 'http://localhost:8081',
    },
  },
  vite: {
    plugins: [tailwindcss()],
  },
  css: ['./assets/main.css'],
})

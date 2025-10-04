const process = require('node:process')

module.exports = {
  apps: [
    {
      name: 'frontend',
      script: '.output/server/index.mjs',
      env: {
        NUXT_PUBLIC_API_ENVIRONMENT: process.env.NUXT_PUBLIC_API_ENVIRONMENT || 'prod',
        PORT: process.env.PORT || 3000,
      },
      instances: 2,
      exec_mode: 'cluster',
    },
  ],
}

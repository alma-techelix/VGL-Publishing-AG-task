# Frontend

Nuxt 4 application with Vue 3 and Tailwind CSS.

## Stack
- Nuxt 4 (Vue 3)
- Vite
- Tailwind CSS + DaisyUI

## Host ystem requirements
- Node.js 20+ (LTS recommended)
- pnpm 10.12.x (project uses `packageManager` lock to 10.12.3)
- Modern browser (Chromium, Firefox, Safari)
- Network: able to bind `localhost:3000`
- PM2 is included as a dependency and used by `pnpm prod` (no global install needed)

## Project Layout
- `app/` — pages, components, composables (e.g. `app/composables/useApi.ts`)
- `nuxt.config.ts` — Nuxt configuration and runtime config

## Quick Start
This workspace uses pnpm.

```bash
pnpm install
pnpm dev
```

App runs at `http://localhost:3000` by default.

## Build & Preview
```bash
pnpm build
pnpm preview
```

## Build & Production
```bash
pnpm build
pnpm prod
```

## Tests
Unit tests are powered by Vitest.

```bash
pnpm test
pnpm test:watch
```

 # Monorepo Overview

 This repository contains a lightweight web application split into two apps that live side by side:

 - `packages/backend/` — PHP HTTP service (Swoole + Doctrine) exposing read-only endpoints.
 - `packages/frontend/` — Nuxt 4 (Vue 3) frontend consuming the backend API.

 The fictional scenario: an existing backend and a separate frontend have been brought together into a single repository. The objective is to run and deploy them in an AWS environment while keeping developer experience (DX) smooth for day-to-day work.

 ## Tech Stack
 - Backend: PHP 8.1+, Swoole HTTP server, Doctrine ORM/DBAL, SQLite (dev) / MySQL (prod).
 - Frontend: Nuxt 4, Vue 3, Vite, Tailwind CSS.

 ## Goals
 - Keep local development fast and simple for both apps.
 - Provide a clear path to build, test, and deploy each app independently.
 - Use AWS primitives that are familiar and maintainable over time.

 ## Repository Structure
 ```
 packages/
   backend/   # PHP service, Composer scripts, .env config
   frontend/  # Nuxt app, pnpm scripts, runtime config
 ```

 ## Local Development
 - Backend: see `packages/backend/README.md` for Composer scripts, `.env` setup, and endpoints.
 - Frontend: see `packages/frontend/README.md` for pnpm scripts and runtime configuration.

 Typical flow:
 1) Start backend API (defaults to `http://127.0.0.1:8080`).
 2) Start frontend dev server (defaults to `http://localhost:3000`).

 For detailed app instructions, refer to the READMEs in `packages/backend/` and `packages/frontend/`.

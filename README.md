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

### Option 1: Docker (Recommended)
Development uses SQLite (bundled `dev.db`) for zero‑setup speed. MySQL runs only under the `production` profile.

```bash
# Start dev (frontend + backend with SQLite)
docker compose up -d backend frontend

# Or simply (starts only defined dev services; MySQL omitted by profile):
docker compose up -d

# Check service health
docker compose ps

# View logs
docker compose logs -f backend

# Stop services
docker compose down
```

Dev service URLs:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- (SQLite file at `packages/backend/data/dev.db`)

### Makefile Shortcuts
After cloning you can use the provided `Makefile`:
```bash
make up          # start dev stack (SQLite)
make smoke       # run smoke checks (health + sample endpoint)
make logs        # tail logs
make down        # stop stack
make prod-up     # start production profile (MySQL + prod images)
make prod-smoke  # run smoke against prod profile endpoints
```

To run with MySQL (e.g., production-like):
```bash
docker compose --profile production up -d mysql backend-prod frontend-prod
```
Production-profile URLs:
- Frontend: http://localhost:3001
- Backend API: http://localhost:8081
- MySQL: localhost:3307 (container 3306 mapped to 3307)

 ### Option 2: Native Development
 - Backend: see `packages/backend/README.md` for Composer scripts, `.env` setup, and endpoints.
 - Frontend: see `packages/frontend/README.md` for pnpm scripts and runtime configuration.

 Typical flow:
 1) Start backend API (defaults to `http://127.0.0.1:8080`).
 2) Start frontend dev server (defaults to `http://localhost:3000`).

 For detailed app instructions, refer to the READMEs in `packages/backend/` and `packages/frontend/`.

 ## Production Deployment

 ### Docker Production Build
 ```bash
 # Build production images
 docker-compose --profile production build
 
 # Run production services
 docker-compose --profile production up -d
 ```
 
 Production services:
 - Frontend: http://localhost:3001
 - Backend API: http://localhost:8081

 ## Environment Configuration

These are the minimal environment variables now in use.

Dev (`.env.development`):
```
DB_DRIVER=sqlite
DB_PATH=data/dev.db
HTTP_HOST=127.0.0.1
HTTP_PORT=8080
NUXT_PUBLIC_API_ENVIRONMENT=dev
NUXT_PUBLIC_API_BASE_URL_DEV=http://localhost:8080
PORT=3000
```

Prod (`.env.production`):
```
DB_DRIVER=mysql
DB_HOST=mysql
DB_PORT=3306
DB_NAME=app
DB_USER=app
DB_PASS=*** (supply securely)
HTTP_HOST=0.0.0.0
HTTP_PORT=8080
NUXT_PUBLIC_API_ENVIRONMENT=prod
NUXT_PUBLIC_API_BASE_URL_PROD=http://backend-prod:8080
PORT=3000
```

Reference templates:
- `.env.example` (optional scaffold)
- `.env.development` (local dev)
- `.env.production` (production profile)

## AWS Deployment

The repository includes Terraform infrastructure for AWS deployment:

- **ECS Fargate** cluster for containerized applications
- **Aurora MySQL** database cluster
- **Application Load Balancer** with SSL termination
- **VPC** with public/private subnets
- **Auto-scaling** policies
- **CloudWatch** monitoring

See `terraform/` directory for complete infrastructure as code.

## CI/CD

GitHub Actions workflows are configured for:
- Automated testing (PHPUnit, Vitest, ESLint)
- Docker image building
- Security scanning
- ECR publishing

Workflows trigger on pushes to main branch and pull requests.

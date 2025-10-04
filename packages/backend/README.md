# Backend

Lightweight PHP HTTP service using Swoole and Doctrine ORM.

## Stack
- PHP 8.1+
- Swoole HTTP server
- Doctrine ORM / DBAL
- SQLite for development (switchable to MySQL)

## Host System requirements
- PHP 8.1+ CLI
- PHP extensions:
  - Swoole (`pecl install swoole`) — required to run the HTTP server (macOS/Linux)
  - PDO SQLite (`pdo_sqlite`) — required for the default development database
  - PDO MySQL (`pdo_mysql`) — only if you switch to MySQL
- Composer 2.x
- SQLite 3 CLI (optional) — useful to inspect `data/dev.db`
- Network: able to bind `127.0.0.1:8080`

Note: Swoole is best supported on macOS/Linux. On Windows, use WSL2.

## Project Layout
- `bin/server.php` – server entrypoint
- `src/` – bootstrap, router, and domain code
- `data/dev.db` – development SQLite database
- `.env.example` – sample environment file

## Quick Start
```bash
composer install
cp .env.example .env
composer run start
```

Server listens on `http://127.0.0.1:8080` by default. Health check: `GET /health`.

## Endpoints (read-only)
- `GET /artists`, `GET /artists/{id}`
- `GET /albums`, `GET /albums/{id}`
- `GET /genres`, `GET /genres/{id}`

## Configuration
Edit `.env` to select the database:

```env
DB_DRIVER=sqlite
DB_PATH=data/dev.db
# Or MySQL
# DB_DRIVER=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_NAME=app
# DB_USER=app
# DB_PASS=app
```

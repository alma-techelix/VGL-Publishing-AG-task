SHELL := /bin/sh

.DEFAULT_GOAL := help

## ---- Variables ----
COMPOSE := docker compose

## ---- Help ----
help: ## Show this help
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## ' Makefile | sort | awk 'BEGIN {FS=":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

## ---- Dev (SQLite) ----
up: ## Start dev stack (backend + frontend using SQLite)
	$(COMPOSE) up -d

down: ## Stop all containers
	$(COMPOSE) down

logs: ## Tail all service logs
	$(COMPOSE) logs -f

smoke: ## Run simple smoke tests against dev stack
	sh scripts/dev-smoke.sh

reup: down up ## Restart stack (shortcut)

## ---- Prod Profile (MySQL) ----
prod-up: ## Start production profile services (MySQL + backend-prod + frontend-prod)
	$(COMPOSE) --profile production up -d mysql backend-prod frontend-prod

prod-down: ## Stop production profile services
	$(COMPOSE) down

prod-logs: ## Tail production profile logs
	$(COMPOSE) logs -f backend-prod frontend-prod mysql

prod-smoke: ## Basic health check for production profile endpoints
	BACKEND_URL=http://localhost:8081 FRONTEND_URL=http://localhost:3001 sh scripts/dev-smoke.sh

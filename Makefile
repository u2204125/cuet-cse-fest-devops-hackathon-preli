# Docker Services:
#   up - Start services (use: make up [service...] or make up MODE=prod, ARGS="--build" for options)
#   down - Stop services (use: make down [service...] or make down MODE=prod, ARGS="--volumes" for options)
#   build - Build containers (use: make build [service...] or make build MODE=prod)
#   logs - View logs (use: make logs [service] or make logs SERVICE=backend, MODE=prod for production)
#   restart - Restart services (use: make restart [service...] or make restart MODE=prod)
#   shell - Open shell in container (use: make shell [service] or make shell SERVICE=gateway, MODE=prod, default: backend)
#   ps - Show running containers (use MODE=prod for production)
#
# Convenience Aliases (Development):
#   dev-up - Alias: Start development environment
#   dev-down - Alias: Stop development environment
#   dev-build - Alias: Build development containers
#   dev-logs - Alias: View development logs
#   dev-restart - Alias: Restart development services
#   dev-shell - Alias: Open shell in backend container
#   dev-ps - Alias: Show running development containers
#   backend-shell - Alias: Open shell in backend container
#   gateway-shell - Alias: Open shell in gateway container
#   mongo-shell - Open MongoDB shell
#
# Convenience Aliases (Production):
#   prod-up - Alias: Start production environment
#   prod-down - Alias: Stop production environment
#   prod-build - Alias: Build production containers
#   prod-logs - Alias: View production logs
#   prod-restart - Alias: Restart production services
#
# Backend:
#   backend-build - Build backend TypeScript
#   backend-install - Install backend dependencies
#   backend-type-check - Type check backend code
#   backend-dev - Run backend in development mode (local, not Docker)
#
# Database:
#   db-reset - Reset MongoDB database (WARNING: deletes all data)
#   db-backup - Backup MongoDB database
#
# Cleanup:
#   clean - Remove containers and networks (both dev and prod)
#   clean-all - Remove containers, networks, volumes, and images
#   clean-volumes - Remove all volumes
#
# Utilities:
#   status - Alias for ps
#   health - Check service health
#
# Help:
#   help - Display this help message

# Variables
MODE ?= dev
ifeq ($(MODE),dev)
	COMPOSE_FILE = docker/compose.development.yaml
else
	COMPOSE_FILE = docker/compose.production.yaml
endif

# Docker Compose Commands
.PHONY: up
up:
	sudo docker compose -f $(COMPOSE_FILE) up -d $(ARGS)

.PHONY: down
down:
	sudo docker compose -f $(COMPOSE_FILE) down $(ARGS)

.PHONY: build
build:
	sudo docker compose -f $(COMPOSE_FILE) build $(ARGS)

.PHONY: logs
logs:
	sudo docker compose -f $(COMPOSE_FILE) logs -f $(SERVICE)

.PHONY: restart
restart:
	sudo docker compose -f $(COMPOSE_FILE) restart $(SERVICE)

.PHONY: shell
shell:
	sudo docker compose -f $(COMPOSE_FILE) exec $(or $(SERVICE),backend) sh

.PHONY: ps
ps:
	sudo docker compose -f $(COMPOSE_FILE) ps

# Development Aliases
.PHONY: dev-up
dev-up:
	$(MAKE) up MODE=dev

.PHONY: dev-down
dev-down:
	$(MAKE) down MODE=dev

.PHONY: dev-build
dev-build:
	$(MAKE) build MODE=dev

.PHONY: dev-logs
dev-logs:
	$(MAKE) logs MODE=dev

.PHONY: dev-restart
dev-restart:
	$(MAKE) restart MODE=dev

.PHONY: dev-shell
dev-shell:
	$(MAKE) shell MODE=dev

.PHONY: dev-ps
dev-ps:
	$(MAKE) ps MODE=dev

.PHONY: backend-shell
backend-shell:
	$(MAKE) shell SERVICE=backend

.PHONY: gateway-shell
gateway-shell:
	$(MAKE) shell SERVICE=gateway

.PHONY: mongo-shell
mongo-shell:
	sudo docker compose -f $(COMPOSE_FILE) exec mongodb mongosh -u admin -p admin123

# Production Aliases
.PHONY: prod-up
prod-up:
	$(MAKE) up MODE=prod

.PHONY: prod-down
prod-down:
	$(MAKE) down MODE=prod

.PHONY: prod-build
prod-build:
	$(MAKE) build MODE=prod

.PHONY: prod-logs
prod-logs:
	$(MAKE) logs MODE=prod

.PHONY: prod-restart
prod-restart:
	$(MAKE) restart MODE=prod

# Backend Commands
.PHONY: backend-build
backend-build:
	cd backend && npm run build

.PHONY: backend-install
backend-install:
	cd backend && npm install

.PHONY: backend-type-check
backend-type-check:
	cd backend && npm run type-check

.PHONY: backend-dev
backend-dev:
	cd backend && npm run dev

# Database Commands
.PHONY: db-reset
db-reset:
	sudo docker compose -f $(COMPOSE_FILE) exec mongodb mongosh -u admin -p admin123 --eval "db.dropDatabase()"

.PHONY: db-backup
db-backup:
	sudo docker compose -f $(COMPOSE_FILE) exec mongodb mongodump --out=/data/backup

# Cleanup Commands
.PHONY: clean
clean:
	sudo docker compose -f docker/compose.development.yaml down
	sudo docker compose -f docker/compose.production.yaml down

.PHONY: clean-all
clean-all:
	$(MAKE) clean
	sudo docker compose -f docker/compose.development.yaml down -v --rmi all
	sudo docker compose -f docker/compose.production.yaml down -v --rmi all

.PHONY: clean-volumes
clean-volumes:
	sudo docker volume rm mongo_data mongo_data_dev 2>/dev/null || true

# Utilities
.PHONY: status
status:
	$(MAKE) ps

.PHONY: health
health:
	@echo "Checking service health..."
	@curl -s http://localhost:5921/health || echo "Gateway not responding"

.PHONY: help
help:
	@echo "Please refer to the comments at the top of this Makefile for available commands"


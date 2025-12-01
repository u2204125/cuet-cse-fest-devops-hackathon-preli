# ============================================
# CUET CSE Fest DevOps Hackathon - Makefile
# ============================================
#
# Quick Start Commands:
#   make dev              - Start development environment
#   make up               - Start production environment
#   make down             - Stop all services
#   make test-health      - Test gateway health
#   make test-backend-check - Test backend via gateway
#
# All Available Commands:
#   make help             - Show detailed command list

# ============================================
# Variables
# ============================================
MODE ?= prod
ifeq ($(MODE),dev)
	COMPOSE_FILE = docker/compose.development.yaml
else
	COMPOSE_FILE = docker/compose.production.yaml
endif

# ============================================
# Hackathon Required Commands
# ============================================
.PHONY: dev
dev:
	@echo "🚀 Starting development environment..."
	@sudo docker compose -f docker/compose.development.yaml up -d
	@echo "✅ Development environment started!"

.PHONY: up
up:
	@echo "🚀 Starting production environment..."
	@sudo docker compose -f $(COMPOSE_FILE) up -d $(ARGS)
	@echo "✅ Production environment started!"

.PHONY: down
down:
	@echo "🛑 Stopping services..."
	@sudo docker compose -f $(COMPOSE_FILE) down $(ARGS)
	@echo "✅ Services stopped!"

.PHONY: test-health
test-health:
	@echo "🏥 Testing Gateway health..."
	@curl http://localhost:5921/health

.PHONY: test-backend-check
test-backend-check:
	@echo "🏥 Testing Backend health via Gateway..."
	@curl http://localhost:5921/api/health

# ============================================
# Docker Operations
# ============================================
.PHONY: build
build:
	@sudo docker compose -f $(COMPOSE_FILE) build $(ARGS)

.PHONY: logs
logs:
	@sudo docker compose -f $(COMPOSE_FILE) logs -f $(SERVICE)

.PHONY: ps
ps:
	@sudo docker compose -f $(COMPOSE_FILE) ps

.PHONY: restart
restart:
	@sudo docker compose -f $(COMPOSE_FILE) restart $(SERVICE)

# ============================================
# Cleanup Commands
# ============================================
.PHONY: clean
clean:
	@echo "🧹 Cleaning up containers and networks..."
	@sudo docker compose -f docker/compose.development.yaml down 2>/dev/null || true
	@sudo docker compose -f docker/compose.production.yaml down 2>/dev/null || true
	@echo "✅ Cleanup complete!"

.PHONY: clean-all
clean-all:
	@echo "🧹 Removing all containers, networks, volumes, and images..."
	@sudo docker compose -f docker/compose.development.yaml down -v --rmi all 2>/dev/null || true
	@sudo docker compose -f docker/compose.production.yaml down -v --rmi all 2>/dev/null || true
	@echo "✅ Deep cleanup complete!"

# ============================================
# Help
# ============================================
.PHONY: help
help:
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║   CUET CSE Fest DevOps Hackathon - Makefile Commands      ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "📋 Essential Commands:"
	@echo "  make dev                 - Start development environment"
	@echo "  make up                  - Start production environment"
	@echo "  make down                - Stop all services"
	@echo "  make test-health         - Test gateway health endpoint"
	@echo "  make test-backend-check  - Test backend via gateway"
	@echo ""
	@echo "🔧 Docker Operations:"
	@echo "  make build               - Build Docker images"
	@echo "  make logs                - View service logs (add SERVICE=name)"
	@echo "  make ps                  - Show running containers"
	@echo "  make restart             - Restart services"
	@echo ""
	@echo "🧹 Cleanup:"
	@echo "  make clean               - Remove containers and networks"
	@echo "  make clean-all           - Remove everything (containers, volumes, images)"
	@echo ""
	@echo "💡 Examples:"
	@echo "  make up MODE=prod        - Start production explicitly"
	@echo "  make logs SERVICE=gateway - View gateway logs"
	@echo "  make build ARGS='--no-cache' - Build without cache"
	@echo ""


# Load environment variables
include .env
export

# Image configuration (tag matches Atlantis version for traceability)
IMAGE_NAME := atlantis-packer
IMAGE_TAG := $(ATLANTIS_VERSION)
FULL_IMAGE_NAME := $(IMAGE_NAME):$(IMAGE_TAG)

# Registry variables (optional)
REGISTRY_IMAGE := $(REGISTRY_URL)/$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: help build push start stop restart logs clean setup version test shell status dev-build dev-start validate-env update-versions

# Default target
help: ## Show this help message
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Create .env file from .env.example
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "Created .env file from .env.example"; \
		echo "Please edit .env with your actual values"; \
	else \
		echo ".env file already exists"; \
	fi

version: ## Show configured versions
	@echo "Configured versions:"
	@echo "  Atlantis: $(ATLANTIS_VERSION)"
	@echo "  Packer: $(PACKER_VERSION)"
	@echo "  Image: $(FULL_IMAGE_NAME)"

validate-env: ## Validate required environment variables
	@echo "Validating environment variables..."
	@test -n "$(ATLANTIS_VERSION)" || (echo "Error: ATLANTIS_VERSION not set" && exit 1)
	@test -n "$(PACKER_VERSION)" || (echo "Error: PACKER_VERSION not set" && exit 1)
	@test -n "$(ATLANTIS_URL)" || (echo "Error: ATLANTIS_URL not set" && exit 1)
	@test -n "$(GITHUB_TOKEN)" || (echo "Error: GITHUB_TOKEN not set" && exit 1)
	@echo "Environment validation passed!"

build: validate-env ## Build the custom Atlantis Docker image with configurable versions
	@echo "Building $(FULL_IMAGE_NAME)..."
	@echo "  Atlantis version: $(ATLANTIS_VERSION)"
	@echo "  Packer version: $(PACKER_VERSION)"
	docker build \
		--build-arg ATLANTIS_VERSION=$(ATLANTIS_VERSION) \
		--build-arg PACKER_VERSION=$(PACKER_VERSION) \
		-t $(FULL_IMAGE_NAME) .
	@echo "Build complete: $(FULL_IMAGE_NAME)"

push: build ## Build and push image to registry
	@if [ -z "$(REGISTRY_URL)" ]; then \
		echo "Error: REGISTRY_URL not set in .env"; \
		exit 1; \
	fi
	@echo "Tagging image for registry..."
	docker tag $(FULL_IMAGE_NAME) $(REGISTRY_IMAGE)
	@echo "Logging in to registry..."
	echo $(REGISTRY_PASSWORD) | docker login $(REGISTRY_URL) -u $(REGISTRY_USERNAME) --password-stdin
	@echo "Pushing $(REGISTRY_IMAGE)..."
	docker push $(REGISTRY_IMAGE)
	@echo "Push complete: $(REGISTRY_IMAGE)"

start: build ## Build image and start Atlantis
	@echo "Starting Atlantis..."
	docker compose up -d
	@echo "Atlantis started successfully"
	@echo "Access Atlantis at: $(ATLANTIS_URL)"

stop: ## Stop Atlantis
	@echo "Stopping Atlantis..."
	docker compose down
	@echo "Atlantis stopped"

restart: stop start ## Restart Atlantis

logs: ## Show Atlantis logs
	docker compose logs -f atlantis

status: ## Show Atlantis status
	docker compose ps

clean: ## Clean up Docker images and containers
	@echo "Cleaning up..."
	docker compose down -v
	docker rmi $(FULL_IMAGE_NAME) 2>/dev/null || true
	docker system prune -f
	@echo "Cleanup complete"

shell: ## Open shell in running Atlantis container
	docker compose exec atlantis sh

test: ## Test Packer and Atlantis installations in container
	@echo "Testing installations..."
	docker compose exec atlantis atlantis version
	docker compose exec atlantis packer version
	@echo "All tests passed!"

# Development targets
dev-build: validate-env ## Build without cache for development
	@echo "Building $(FULL_IMAGE_NAME) without cache..."
	@echo "  Atlantis version: $(ATLANTIS_VERSION)"
	@echo "  Packer version: $(PACKER_VERSION)"
	docker build --no-cache \
		--build-arg ATLANTIS_VERSION=$(ATLANTIS_VERSION) \
		--build-arg PACKER_VERSION=$(PACKER_VERSION) \
		-t $(FULL_IMAGE_NAME) .

dev-start: dev-build ## Build and start in development mode
	docker compose up

# Utility targets
update-versions: ## Update to latest versions (interactive)
	@echo "Current versions:"
	@echo "  Atlantis: $(ATLANTIS_VERSION)"
	@echo "  Packer: $(PACKER_VERSION)"
	@echo ""
	@echo "Check latest versions at:"
	@echo "  Atlantis: https://github.com/runatlantis/atlantis/releases"
	@echo "  Packer: https://github.com/hashicorp/packer/releases"
	@echo ""
	@echo "Update versions in your .env file and run 'make build'"

rebuild: clean build ## Clean and rebuild everything

info: ## Show current configuration
	@echo "Current Configuration:"
	@echo "  Image: $(FULL_IMAGE_NAME)"
	@echo "  Atlantis Version: $(ATLANTIS_VERSION)"
	@echo "  Packer Version: $(PACKER_VERSION)"
	@echo "  Atlantis URL: $(ATLANTIS_URL)"
	@echo "  Atlantis Port: $(ATLANTIS_PORT)"
	@echo "  GitHub User: $(GITHUB_USERNAME)"
	@echo "  Repo Allowlist: $(REPO_ALLOWLIST)"
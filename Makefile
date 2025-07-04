# Variables
IMAGE_NAME := atlantis-packer
IMAGE_TAG := latest
FULL_IMAGE_NAME := $(IMAGE_NAME):$(IMAGE_TAG)

# Load environment variables
include .env
export

# Registry variables (optional)
REGISTRY_IMAGE := $(REGISTRY_URL)/$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: help build push start stop restart logs clean setup

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

build: ## Build the custom Atlantis Docker image
	@echo "Building $(FULL_IMAGE_NAME)..."
	docker build -t $(FULL_IMAGE_NAME) .
	@echo "Build complete: $(FULL_IMAGE_NAME)"

push: build ## Build and push image to registry
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
	docker compose exec atlantis /bin/bash

test: ## Test Packer installation in container
	docker compose exec atlantis packer version

# Development targets
dev-build: ## Build without cache for development
	docker build --no-cache -t $(FULL_IMAGE_NAME) .

dev-start: dev-build ## Build and start in development mode
	docker-compose up
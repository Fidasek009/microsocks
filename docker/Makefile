SHELL := /bin/bash
.DEFAULT_GOAL := help

IMAGE ?= ghcr.io/fidasek009/microsocks
TAG ?= latest
FULL := $(IMAGE):$(TAG)

.PHONY: help
help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build the docker image using project root as context
	docker build -f Dockerfile -t $(FULL) ..

.PHONY: push
push: ## Push the image to registry (ensure you're logged in)
	docker push $(FULL)

.PHONY: compose-up
compose-up: ## Start the service using docker compose
	docker compose -f docker-compose.yml up -d

.PHONY: compose-down
compose-down: ## Stop and remove the compose services
	docker compose -f docker-compose.yml down

.PHONY: compose-build
compose-build: ## Build images defined in the compose file
	docker compose -f docker-compose.yml build

.PHONY: compose-logs
compose-logs: ## Follow logs for compose services
	docker compose -f docker-compose.yml logs -f

.PHONY: compose-restart
compose-restart: ## Restart compose services
	docker compose -f docker-compose.yml restart

SHELL := /bin/bash

IMAGE ?= ghcr.io/fidasek009/microsocks
TAG ?= latest
FULL := $(IMAGE):$(TAG)

.PHONY: help build push
help:
	@echo "Usage: make [build|push] IMAGE=<repo/name> TAG=<tag>"

build: ## Build the docker image using project root as context
	docker build -f Dockerfile -t $(FULL) ..

push: ## Push the image to registry (ensure you're logged in)
	docker push $(FULL)

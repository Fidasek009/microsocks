SHELL := /bin/bash
.DEFAULT_GOAL := help

RELEASE_NAME ?= microsocks
NAMESPACE ?= default

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## Install the chart
	helm install $(RELEASE_NAME) . -n $(NAMESPACE)

.PHONY: upgrade
upgrade: ## Upgrade the chart
	helm upgrade $(RELEASE_NAME) . -n $(NAMESPACE)

.PHONY: uninstall
uninstall: ## Uninstall the chart
	helm uninstall $(RELEASE_NAME) -n $(NAMESPACE)

.PHONY: template
template: ## Render templates locally for debugging
	helm template $(RELEASE_NAME) .

.PHONY: lint
lint: ## Lint the chart
	helm lint .

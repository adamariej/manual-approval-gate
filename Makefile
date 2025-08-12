TARGET = kubernetes
NAMESPACE = tekton-pipelines
M = $(shell printf "\033[34;1m🐱\033[0m")


apply: ## Apply config to the current cluster
	@echo "$(M) ko apply on config/$(TARGET)"
	@ko apply -f config/$(TARGET)

helm:
	echo "$(M) helm upgrade on config/$(TARGET)"
	helm upgrade --install --reset-values --namespace $(NAMESPACE) devel ./config/helm

.PHONY: apply helm

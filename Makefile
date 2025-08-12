TARGET = kubernetes
NAMESPACE = tekton-pipelines
REGISTRY =
HELM_PATH = /helm
RELEASE = 0.7.0
M = $(shell printf "\033[34;1m🐱\033[0m")


apply: ## Apply config to the current cluster
	@echo "$(M) ko apply on config/$(TARGET)"
	@ko apply -f config/$(TARGET)

helm-upgrade:
	@echo "$(M) helm upgrade on config/$(TARGET)"
	@helm upgrade --install --reset-values --namespace $(NAMESPACE) devel ./config/helm

ifdef REGISTRY
push-images: registry-login
	@echo "$(M) deploy images to $(REGISTRY)"
	@KO_DOCKER_REPO=$(REGISTRY) ko build ./cmd/controller --tags $(RELEASE)
	@KO_DOCKER_REPO=$(REGISTRY) ko build ./cmd/tkn-approvaltask --tags $(RELEASE)
	@KO_DOCKER_REPO=$(REGISTRY) ko build ./cmd/webhook --tags $(RELEASE)

registry-login:
	@echo "$(M) Login to $(REGISTRY)"
	@echo "${REGISTRY_TOKEN}" | helm registry login $(REGISTRY) --password-stdin

helm-push: registry-login
	@echo "$(M) Push to registry $(REGISTRY)"
	@helm package config/helm --version 0.7.0
	@echo "Push to oci://$(REGISTRY):$(HELM_PATH)"
	@helm push tekton-manual-approval-gate-0.7.0.tgz oci://$(REGISTRY)$(HELM_PATH)
else
push-images:
	$(error REGISTRY is not set)
helm-push:
	$(error REGISTRY is not set)
endif



.PHONY: apply helm helm-upgrade helm-push registry-login

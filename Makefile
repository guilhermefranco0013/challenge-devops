# Makefile for challenge-devops
# Use `make <target>` to run common project workflows from the repository root.

PYTHON ?= python3
PIP ?= pip
APP_DIR := app
REQUIREMENTS := $(APP_DIR)/requirements.txt
DOCKERFILE := deploy/docker/Dockerfile
COMPOSE_FILE := deploy/compose/docker-compose.yml
K8S_DIR := deploy/kubernetes
HELM_CHART := deploy/helm/challenge-devops
IMAGE_NAME := challenge-devops
HELM_RELEASE := challenge-devops
HELM_NAMESPACE := challenge-devops
DEV_PACKAGES := ruff black pre-commit
VENV_BIN := $(APP_DIR)/.venv/bin
VENV_PIP := $(VENV_BIN)/pip
STRICT ?= false
FAIL_ON_VULNS ?= false
.DEFAULT_GOAL := help

.PHONY: help	venv	install	deps	dev-setup	dev-deps	lint	fmt	precommit-install	precommit-run	validate	test	run	docker-build	docker-run	compose-up	compose-down	compose-logs	k8s-apply	k8s-delete	k8s-status	k8s-port-forward	port-forward	k8s-logs helm-lint	helm-template	trivy	check	helm-install	helm-upgrade	helm-uninstall	clean

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Available targets:"
	@echo "  help            - Show this help message"
	@echo "  venv            - Create a Python virtualenv in ./app/.venv"
	@echo "  install         - Install Python dependencies from $(REQUIREMENTS)"
	@echo "  test            - Run pytest unit tests"
	@echo "  validate        - Validate Python imports and run tests"
	@echo "  run             - Run the FastAPI app locally with Uvicorn"
	@echo "  docker-build    - Build the Docker image from $(DOCKERFILE)"
	@echo "  docker-run      - Run the built Docker image locally on port 8000"
	@echo "  compose-up      - Start the local Docker Compose environment"
	@echo "  compose-down    - Stop the local Docker Compose environment"
	@echo "  compose-logs    - Follow logs for the Compose services"
	@echo "  k8s-apply       - Apply raw Kubernetes manifests from $(K8S_DIR)"
	@echo "  k8s-delete      - Delete raw Kubernetes resources"
	@echo "  k8s-status      - Show Kubernetes resources in the challenge namespace"
	@echo "  k8s-port-forward - Forward service port 80 to localhost:8082"
	@echo "  dev-setup       - Create venv and install development tools"
	@echo "  lint            - Run ruff lint checks against app and app/tests"
	@echo "  fmt             - Format Python code with black"
	@echo "  precommit-install - Install Git hooks for pre-commit"
	@echo "  precommit-run   - Run pre-commit hooks on all files"
	@echo "  helm-install    - Install the Helm chart into namespace $(HELM_NAMESPACE)"
	@echo "  helm-upgrade    - Upgrade the existing Helm release"
	@echo "  helm-uninstall  - Uninstall the Helm release"
	@echo "  clean           - Remove Python cache, pytest cache and temporary files"

venv-create:
	@echo "Creating Python virtualenv in $(APP_DIR)/.venv..."
	cd $(APP_DIR) && $(PYTHON) -m venv .venv
	@echo "Activate with: source $(APP_DIR)/.venv/bin/activate"

venv:
	@echo "Run:"
	@echo "source app/.venv/bin/activate"

install: deps

dev-setup: venv dev-deps
	@echo "Development environment ready: venv created and tools installed."

dev-deps:
	@echo "Installing development tools: $(DEV_PACKAGES)..."
	$(VENV_PIP) install --upgrade $(DEV_PACKAGES)

deps:
	@echo "Installing Python dependencies from $(REQUIREMENTS)..."
	$(VENV_PIP) install --upgrade pip
	$(VENV_PIP) install -r $(REQUIREMENTS)

lint:
	@echo "Running ruff lint checks on app and tests..."
	$(VENV_BIN)/ruff check app app/tests

fmt:
	@echo "Formatting Python code with black..."
	$(VENV_BIN)/black app app/tests

precommit-install:
	@echo "Installing pre-commit git hooks..."
	$(VENV_BIN)/pre-commit install

precommit-run:
	@echo "Running pre-commit hooks on all files..."
	$(VENV_BIN)/pre-commit run --all-files

validate:
	@echo "Validating application imports..."
	$(VENV_BIN)/python -c "from main import app"
	@echo "Running tests..."
	$(VENV_BIN)/pytest app/tests -q

test:
	@echo "Running pytest..."
	$(VENV_BIN)/pytest app/tests -q

run:
	@echo "Starting FastAPI with Uvicorn..."
	$(VENV_BIN)/uvicorn main:app --host 0.0.0.0 --port 8000

docker-build:
	@echo "Building Docker image $(IMAGE_NAME)..."
	docker build -t $(IMAGE_NAME) -f $(DOCKERFILE) .

docker-run:
	@echo "Running Docker image $(IMAGE_NAME) on port 8000..."
	docker run --rm -p 8000:8000 $(IMAGE_NAME)

compose-up:
	@echo "Starting Docker Compose stack from $(COMPOSE_FILE)..."
	docker compose -f $(COMPOSE_FILE) up --build -d

compose-down:
	@echo "Stopping Docker Compose stack..."
	docker compose -f $(COMPOSE_FILE) down

compose-logs:
	@echo "Following Docker Compose logs..."
	docker compose -f $(COMPOSE_FILE) logs --follow

kube-apply:
	@echo "Applying Kubernetes manifests from $(K8S_DIR)..."
	kubectl apply -f $(K8S_DIR)

kube-delete:
	@echo "Deleting Kubernetes resources from $(K8S_DIR)..."
	kubectl delete -f $(K8S_DIR) --ignore-not-found

kube-status:
	@echo "Listing Kubernetes resources in namespace $(HELM_NAMESPACE)..."
	kubectl get all -n $(HELM_NAMESPACE)

kube-port-forward:
	@echo "Port-forwarding (customizable): SERVICE=${SERVICE:-svc/challenge-devops-service} LOCAL_PORT=${LOCAL_PORT:-8082} REMOTE_PORT=${REMOTE_PORT:-80} NAMESPACE=${NAMESPACE:-$(HELM_NAMESPACE)}"
	kubectl port-forward --address 0.0.0.0 $${SERVICE:-svc/challenge-devops-service} $${LOCAL_PORT:-8082}:$${REMOTE_PORT:-80} -n $${NAMESPACE:-$(HELM_NAMESPACE)}

kube-logs:
	@echo "Tailing logs in namespace $(HELM_NAMESPACE) (attempting label selector app=$(HELM_RELEASE))..."
	@pods="$$(kubectl get pods -n $(HELM_NAMESPACE) -o jsonpath='{.items[*].metadata.name}')"; \
	if [ -z "$$pods" ]; then \
		echo "No pods found in namespace $(HELM_NAMESPACE)"; exit 1; \
	fi; \
	kubectl logs -l app=$(HELM_RELEASE) -n $(HELM_NAMESPACE) -f --tail=200 || kubectl logs -n $(HELM_NAMESPACE) $$(echo $$pods | awk '{print $$1}') -f

helm-lint:
	@echo "Running helm lint on $(HELM_CHART)"
	helm lint $(HELM_CHART)

helm-template:
	@echo "Rendering Helm templates for $(HELM_CHART) (namespace=$(HELM_NAMESPACE))"
	helm template $(HELM_RELEASE) $(HELM_CHART) --namespace $(HELM_NAMESPACE)

trivy:
	@echo "Scanning Docker image $(IMAGE_NAME) with Trivy (FAIL_ON_VULNS=$(FAIL_ON_VULNS))"
	@if [ "$(FAIL_ON_VULNS)" = "true" ]; then \
		trivy image --no-progress --exit-code 1 --severity HIGH,CRITICAL $(IMAGE_NAME); \
	else \
		trivy image --no-progress --severity HIGH,CRITICAL $(IMAGE_NAME) || true; \
	fi

check:
	@echo "Running full project checks: format, lint, tests, helm lint, helm template, build image, trivy (STRICT=$(STRICT))"
	make fmt || exit 1
	make lint || exit 1
	make test || exit 1
	@if [ "$(STRICT)" = "true" ]; then \
		make helm-lint; \
	else \
		make helm-lint || true; \
	fi
	@if [ "$(STRICT)" = "true" ]; then \
		make helm-template; \
	else \
		make helm-template || true; \
	fi
	@if [ "$(STRICT)" = "true" ]; then \
		make docker-build; \
	else \
		make docker-build || true; \
	fi
	@if [ "$(STRICT)" = "true" ]; then \
		make trivy; \
	else \
		make trivy || true; \
	fi

helm-install:
	@echo "Installing Helm chart $(HELM_CHART) into namespace $(HELM_NAMESPACE)..."
	helm install $(HELM_RELEASE) $(HELM_CHART) --namespace $(HELM_NAMESPACE) --create-namespace

helm-upgrade:
	@echo "Upgrading Helm release $(HELM_RELEASE)..."
	helm upgrade $(HELM_RELEASE) $(HELM_CHART) --namespace $(HELM_NAMESPACE) --reuse-values

helm-uninstall:
	@echo "Uninstalling Helm release $(HELM_RELEASE) from namespace $(HELM_NAMESPACE)..."
	helm uninstall $(HELM_RELEASE) --namespace $(HELM_NAMESPACE) || true

clean:
	@echo "Cleaning Python bytecode and pytest cache..."
	find . -type d -name "__pycache__" -prune -exec rm -rf {} + || true
	rm -rf $(APP_DIR)/.pytest_cache .pytest_cache .ruff_cache $(APP_DIR)/.ruff_cache

kube-debug:
	@echo "========== NAMESPACE =========="
	@echo "$(HELM_NAMESPACE)"
	@echo ""

	@echo "========== PODS =========="
	kubectl get pods -n $(HELM_NAMESPACE) -o wide
	@echo ""

	@echo "========== SERVICES =========="
	kubectl get svc -n $(HELM_NAMESPACE)
	@echo ""

	@echo "========== DEPLOYMENTS =========="
	kubectl get deploy -n $(HELM_NAMESPACE)
	@echo ""

	@echo "========== IMAGES =========="
	kubectl get pods -n $(HELM_NAMESPACE) \
		-o=jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.containers[*].image}{'\n'}{end}"
	@echo ""

	@echo "========== RESTARTS =========="
	kubectl get pods -n $(HELM_NAMESPACE) \
		--sort-by='.status.containerStatuses[0].restartCount'
	@echo ""

	@echo "========== NODE =========="
	kubectl get nodes -A
	@echo ""

	@echo "========== EVENTS =========="
	kubectl get events -n $(HELM_NAMESPACE) \
		--sort-by=.metadata.creationTimestamp | tail -20

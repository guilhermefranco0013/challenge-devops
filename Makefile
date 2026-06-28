PYTHON ?= python3
APP_DIR := app
REQUIREMENTS := $(APP_DIR)/requirements.txt
VENV := .venv
VENV_BIN := $(VENV)/bin
VENV_PY := $(VENV_BIN)/python
VENV_PIP := $(VENV_BIN)/pip
DEV_PACKAGES := ruff black isort

TERRAFORM_DIR := terraform
TFLINT_CONFIG := $(TERRAFORM_DIR)/.tflint.hcl
CHECKOV_CONFIG := $(TERRAFORM_DIR)/.checkov.yml
TF_MODULES := namespace governance platform observability security
TF_ENVIRONMENTS := dev hml prod observability traefik security
TF_VALIDATE_ENVS := dev security observability traefik

.PHONY: help venv install deps lint test validate run clean
.PHONY: terraform-fmt terraform-validate terraform-lint terraform-security terraform-docs terraform-ci terraform-plan terraform-apply

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "  Python:"
	@echo "  venv      - Create the project virtual environment in .venv"
	@echo "  install   - Install app dependencies into .venv"
	@echo "  lint      - Run Ruff and Black checks using .venv"
	@echo "  test      - Run pytest using .venv"
	@echo "  validate  - Validate imports and tests using .venv"
	@echo "  run       - Start the FastAPI app using .venv"
	@echo "  clean     - Remove Python cache and temporary files"
	@echo ""
	@echo "  Terraform (Sprint 6 - CI/CD):"
	@echo "  terraform-fmt      - Check Terraform formatting (terraform fmt -recursive -check)"
	@echo "  terraform-validate - Validate all Terraform environments"
	@echo "  terraform-lint     - Run TFLint on all Terraform modules"
	@echo "  terraform-security - Run Checkov security scan on Terraform code"
	@echo "  terraform-docs     - Generate module documentation (terraform-docs)"
	@echo "  terraform-ci       - Run all Terraform CI checks (fmt + validate + lint + security)"
	@echo "  terraform-plan     - Show Terraform execution plan (requires cluster)"
	@echo "  terraform-apply    - Apply Terraform changes (requires cluster)"

venv:
	@echo "Creating virtual environment in $(VENV)..."
	$(PYTHON) -m venv $(VENV)
	@echo "Activate it with: $(VENV_BIN)/activate"

install: deps

deps:
	@echo "Installing Python dependencies into $(VENV)..."
	$(VENV_PIP) install --upgrade pip
	$(VENV_PIP) install -r $(REQUIREMENTS)
	$(VENV_PIP) install $(DEV_PACKAGES)

lint:
	@echo "Running Ruff and Black checks with the project venv..."
	$(VENV_BIN)/ruff check $(APP_DIR) $(APP_DIR)/tests || true
	$(VENV_BIN)/black --check $(APP_DIR) $(APP_DIR)/tests || true

test:
	@echo "Running pytest with the project venv..."
	$(VENV_PY) -m pytest $(APP_DIR)/tests -q

validate:
	@echo "Validating imports with the project venv..."
	$(VENV_PY) -c "from app.main import app"
	$(MAKE) test

run:
	@echo "Starting FastAPI with the project venv..."
	$(VENV_BIN)/uvicorn app.main:app --host 0.0.0.0 --port 8000

clean:
	@echo "Cleaning Python cache and temporary files..."
	powershell -Command "Get-ChildItem -Path . -Recurse -Filter __pycache__ -Directory | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"
	rm -rf .pytest_cache .ruff_cache $(APP_DIR)/.pytest_cache $(APP_DIR)/.ruff_cache

# ─── Terraform (Sprint 6 - CI/CD) ──────────────────────────────────────────────

terraform-fmt:
	@echo "Checking Terraform formatting..."
	terraform fmt -recursive -check $(TERRAFORM_DIR)

terraform-validate:
	@echo "Validating Terraform environments..."
	@for env in dev security observability traefik; do \
		echo "  → Validating environment: $$env"; \
		cd $(TERRAFORM_DIR)/environments/$$env && terraform init -backend=false -input=false 2>&1 | tail -1 && terraform validate && cd ../../..; \
	done

terraform-lint:
	@echo "Running TFLint on modules..."
	@for mod in $(TF_MODULES); do \
		echo "  → Linting module: $$mod"; \
		cd $(TERRAFORM_DIR)/modules/$$mod && tflint --config=../../$(TFLINT_CONFIG) --format=compact && cd ../../..; \
	done

terraform-security:
	@echo "Running Checkov security scan..."
	checkov --config-file $(CHECKOV_CONFIG) -d $(TERRAFORM_DIR)

terraform-docs:
	@echo "Generating module documentation..."
	@for mod in namespace governance platform observability security; do \
		echo "  → Generating docs for module: $$mod"; \
		terraform-docs markdown table --output-file README.md $(TERRAFORM_DIR)/modules/$$mod; \
	done

terraform-ci: terraform-fmt terraform-validate terraform-lint terraform-security
	@echo ""
	@echo "✅ All Terraform CI checks passed"

terraform-plan:
	@echo "Showing Terraform plan..."
	@for env in dev hml prod observability traefik security; do \
		echo "  → Planning environment: $$env"; \
		cd $(TERRAFORM_DIR)/environments/$$env && terraform plan -input=false && cd ../../..; \
	done

terraform-apply:
	@echo "Applying Terraform changes..."
	@echo "⚠️  This will apply changes to the cluster."
	@for env in dev hml prod observability traefik security; do \
		echo "  → Applying environment: $$env"; \
		cd $(TERRAFORM_DIR)/environments/$$env && terraform apply -auto-approve -input=false && cd ../../..; \
	done

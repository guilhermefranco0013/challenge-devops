PYTHON ?= python3
APP_DIR := app
REQUIREMENTS := $(APP_DIR)/requirements.txt
VENV := .venv
VENV_BIN := $(VENV)/bin
VENV_PY := $(VENV_BIN)/python
VENV_PIP := $(VENV_BIN)/pip
DEV_PACKAGES := ruff black isort

.PHONY: help venv install deps lint test validate run clean

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  venv      - Create the project virtual environment in .venv"
	@echo "  install   - Install app dependencies into .venv"
	@echo "  lint      - Run Ruff and Black checks using .venv"
	@echo "  test      - Run pytest using .venv"
	@echo "  validate  - Validate imports and tests using .venv"
	@echo "  run       - Start the FastAPI app using .venv"
	@echo "  clean     - Remove Python cache and temporary files"

venv:
	@echo "Creating virtual environment in $(VENV)..."
	$(PYTHON) -m venv $(VENV)
	@echo "Activate it with: source $(VENV_BIN)/activate"

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
	find . -type d -name "__pycache__" -prune -exec rm -rf {} + || true
	rm -rf .pytest_cache .ruff_cache $(APP_DIR)/.pytest_cache $(APP_DIR)/.ruff_cache

# Challenge DevOps API

## Application Description

This repository contains a cloud-native DevOps challenge application
built with FastAPI, Docker, Kubernetes, Helm, Prometheus, and Grafana.

The project demonstrates containerization, CI/CD automation,
observability, and Kubernetes deployment practices.

- `/`: root endpoint returning a JSON greeting.
- `/health`: health check endpoint.
- `/metrics`: Prometheus metrics endpoint.

The application is designed for local development, containerized execution, and Kubernetes deployment.

## Stack

- Python 3.12
- FastAPI
- Docker
- Docker Compose
- Kubernetes
- Helm
- Prometheus
- Grafana
- GitHub Actions
- Trivy

## Prerequisites

- Python 3.12+
- pip
- Docker
- Docker Compose
- kubectl
- Helm 3
- Optional: kind or another Kubernetes cluster for local validation

## Local Execution

```bash
cd app
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

Access the service at `http://localhost:8000`.

## Docker Execution

Build the application image:

```bash
docker build -t challenge-devops -f deploy/docker/Dockerfile .
```

Run the container:

```bash
docker run --rm -p 8000:8000 challenge-devops
```

Alternatively, use Docker Compose for local development:

```bash
cd deploy/compose
docker compose up --build
```

## Kubernetes Execution

Apply the Kubernetes manifests:

```bash
kubectl apply -f deploy/kubernetes/
```

If using the ingress resource locally, add the following host entry:
```bash
echo "127.0.0.1 challenge-devops.local" | sudo tee -a /etc/hosts
```

The application can be accessed through the Kubernetes service or through the ingress resource if an ingress controller such as ingress-nginx is installed in the cluster.

## Helm Execution

Install the Helm chart into the `challenge-devops` namespace:

```bash
helm install challenge-devops deploy/helm/challenge-devops --namespace challenge-devops --create-namespace
```

Upgrade the release with updated values:

```bash
helm upgrade challenge-devops deploy/helm/challenge-devops --namespace challenge-devops --reuse-values
```

## Observability Access

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`

## CI/CD

This repository uses GitHub Actions for automation.

Current workflows include:

- Application build validation (`.github/workflows/ci.yml`)
- Docker image build validation
- Security scanning using Trivy (`.github/workflows/security.yml`)

These workflows validate the application and container image as part of the CI pipeline.

## Technical Decisions

- `Python + FastAPI`: chosen for a modern, fast, lightweight web API stack.
- `GitHub Actions`: selected for CI/CD automation and pipeline validation.
- Multi-stage Docker build: used to separate dependency installation from runtime image creation.
- Kubernetes + Helm: supported to demonstrate infrastructure-as-code and deployment parameterization.
- Prometheus and Grafana: included for observability and metrics visualization.

## Architecture

```mermaid
flowchart LR
  Client[HTTP Client] -->|GET /, /health, /metrics| FastAPI[FastAPI App]
  FastAPI -->|Routes| Routes[app/api/routes.py]
  Routes -->|Logs| Logger[structlog JSON Logging]
  Routes -->|Metrics| Metrics[app/observability/metrics.py]
  Metrics -->|Expose| MetricsEndpoint[/metrics]
  MetricsEndpoint -->|Scrape| Prometheus[Prometheus]
  Prometheus -->|Visualize| Grafana[Grafana Dashboard]
```

## Notes

- The current `deploy/kubernetes/ingress.yaml` must be configured for your ingress controller.
- The project uses `.env` configuration via `app/core/config.py`.
- This repository focuses on development and validation environments and does not yet implement production-grade secret management.

## Repository Structure

```text
app/
deploy/
monitoring/
docs/
.github/

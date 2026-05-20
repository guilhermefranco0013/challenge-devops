# Project Architecture

## Overview

This repository implements a lightweight Python application based on FastAPI, with an emphasis on observability and flexible deployment options.

The project structure is organized as follows:

- `app/`
  - `main.py`: FastAPI application entry point.
  - `api/routes.py`: public route definitions for `/`, `/health`, and `/metrics`.
  - `core/config.py`: environment variable loading and centralized configuration.
  - `observability/`: structured logging and Prometheus metrics implementation.
  - `requirements.txt`: Python dependency list.

- `deploy/`
  - `docker/Dockerfile`: multi-stage application image.
  - `compose/docker-compose.yml`: local environment with healthcheck.
  - `kubernetes/`: Kubernetes manifests for namespace, deployment, service, and ingress.
  - `helm/challenge-devops/`: Helm chart for deploy parameterization.

- `monitoring/`
  - `prometheus/prometheus.yml`: Prometheus scraping configuration.
  - `docker-compose.yml`: local Prometheus and Grafana stack.
  - `grafana/dashboards/`: versioned observability dashboards.

## Architectural Flow

The application follows a clear and linear architectural flow:

1. A client makes an HTTP request to the API.
2. FastAPI receives the request and dispatches it to handlers defined in `app/api/routes.py`.
3. Each route performs minimal processing, emits structured logs using `structlog`, and updates metrics.
4. Metrics are exposed at `/metrics` for Prometheus scraping.
5. Prometheus collects metrics from the configured endpoint.
6. Grafana visualizes those metrics using versioned dashboards.

```mermaid
flowchart LR
  Client[HTTP Client] -->|GET /, /health, /metrics| FastAPI[FastAPI]
  FastAPI -->|Routes request| Routes[app/api/routes.py]
  Routes -->|Emits structured log| Logger[structlog JSON]
  Routes -->|Increment counter| Metrics[app_requests_total]
  Routes -->|Expose metrics| MetricsEndpoint[/metrics]
  MetricsEndpoint -->|Scrape| Prometheus[Prometheus]
  Prometheus -->|Visualize| Grafana[Grafana]
```

## Separation of Concerns

The project clearly separates the following responsibilities:

- Presentation/API: `app/main.py` and `app/api/routes.py`.
- Configuration: `app/core/config.py` pulls values from `.env`.
- Observability: `app/observability/logging.py` and `app/observability/metrics.py`.
- Deployment: `deploy/docker`, `deploy/compose`, `deploy/kubernetes`, `deploy/helm`.

This separation supports evolution of the application without mixing business logic with infrastructure concerns.

## Modularization

The codebase is intentionally minimal but modular enough for its scope:

- FastAPI routing is isolated in `app/api/routes.py`.
- Metrics are defined in `app/observability/metrics.py` and imported where needed.
- Structured logging is configured in `app/observability/logging.py`.

This model enables future expansion with additional endpoints, services, or telemetry.

## Observability Architecture

The observability stack includes:

- structured application logging
- Prometheus metrics
- Grafana dashboards

The application adopts three core observability principles:

1. Structured logging with `structlog` in `app/observability/logging.py`.
2. Prometheus metric exposure at `/metrics` via `app/api/routes.py` and `app/observability/metrics.py`.
3. Versioned Grafana dashboards stored in `monitoring/grafana/dashboards/challenge-devops-observability-dashboard.json` to support operational visualization.

## Kubernetes Architecture

The Kubernetes deployment uses:

- namespace isolation for project resources
- Deployment replicas for application availability
- readiness and liveness probes using `/health`
- Service abstraction for internal exposure
- local validation using a Kind cluster
- resource limits and requests

The manifests are stored in `deploy/kubernetes/`
and can be applied directly using `kubectl apply -f`.

## Helm

The Helm chart in `deploy/helm/challenge-devops/` provides a parameterized layer for Kubernetes deployment.

Key chart components include:

- `Chart.yaml`: chart metadata and version.
- `values.yaml`: configurable defaults for `replicaCount`, `image.repository`, `image.tag`, `service.type`, `service.port`, `containerPort`, and `namespace`.
- `templates/deployment.yaml`: deployment template that injects values for the image, probes, port, and namespace.
- `templates/service.yaml`: service template with configurable type and port.

The chart enables the same deployment pattern across different environments by overriding values instead of modifying manifests.

- Development environments can use `image.pullPolicy: Never` and `service.type: NodePort`.
- Staging or production environments can adjust `image.repository`, `image.tag`, and `namespace` declaratively.

The current chart is functional for a basic deployment, but it does not yet include `ingress`, `configMap`, `secret`, `resources`, or `autoscaling` support.

## CI/CD

The repository includes GitHub Actions workflows for:

- application build validation
- Docker image validation
- security scanning using Trivy
- CI pipeline automation

This provides basic CI/CD automation and infrastructure validation.

## Deployment Strategy

The project supports multiple deployment strategies to simplify local development, Kubernetes validation, and Helm-based orchestration.:

- Local deployment via Docker Compose in `deploy/compose/docker-compose.yml`.
- Kubernetes deployment using raw manifests in `deploy/kubernetes/`.
- Kubernetes deployment with Helm using `deploy/helm/challenge-devops/`.

The current implementation focuses on development and validation environments.

For production readiness, future improvements may include:

- ingress controller configuration
- TLS termination
- persistent storage
- centralized log aggregation
- GitOps workflows
- secret management
- horizontal pod autoscaling

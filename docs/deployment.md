# Deployment

## Docker Image

The application image is defined in `deploy/docker/Dockerfile` using a multi-stage build:

- `builder` stage installs Python dependencies with `pip --no-cache-dir --user`.
- `runtime` stage copies the application and configures `PYTHONDONTWRITEBYTECODE` and `PYTHONUNBUFFERED`.
- `EXPOSE 8000` and `HEALTHCHECK` validate the container at runtime.

## Docker Compose

The local development environment is described in `deploy/compose/docker-compose.yml`:

- `app` service is built from `deploy/docker/Dockerfile`.
- Port mapping uses `8000:8000`.
- `env_file` references `../../.env`.
- Healthcheck uses the `/health` endpoint.

This configuration enables quick container execution without requiring a Kubernetes environment.

## Kubernetes

The Kubernetes deployment is available in `deploy/kubernetes/` and includes:

- `namespace.yaml`: defines the `challenge-devops` namespace.
- `deployment.yaml`: deployment with `replicas: 2`, readiness and liveness probes, and `imagePullPolicy: Never`.
- `service.yaml`: A `NodePort` service exposes the application internally through port `80`, forwarding traffic to container port `8000`.
- `ingress.yaml`: present but empty, requiring configuration for external routing.

## Deployment Flow

```mermaid
flowchart LR
    Developer[Developer] --> Docker[Docker Build]

    Docker --> Compose[Docker Compose]

    Docker --> Kubernetes[Kubernetes Deployment]

    Kubernetes --> Helm[Helm Chart]

    Kubernetes --> FastAPI[FastAPI Application]

    FastAPI --> Metrics[/metrics]

    Metrics --> Prometheus[Prometheus]

    Prometheus --> Grafana[Grafana Dashboard]
```

### Notes

- `imagePullPolicy: Never` indicates reliance on a locally available image in the development cluster.
- The current manifest set does not define resources, secrets, config maps, or network policies.

## Helm

The Helm chart is located in `deploy/helm/challenge-devops/` and includes:

- `Chart.yaml`: chart metadata.
- `values.yaml`: configurable values for `replicaCount`, `image`, `service`, `containerPort`, and `namespace`.
- `templates/deployment.yaml`: deployment template with parameters for image, namespace, probes, and port.
- `templates/service.yaml`: service template with configurable type and port.

This chart provides a reusable Kubernetes deployment path, Future improvements may include support for: `resources`, `ingress`, `serviceAccount`, and `configMap` support.

## Execution

### Local with Docker Compose

```bash
cd deploy/compose
docker compose up --build -d
```

### Kubernetes Manual

```bash
kubectl apply -f deploy/kubernetes/
```

### Helm

```bash
helm install challenge-devops deploy/helm/challenge-devops --namespace challenge-devops
```

### Kubernetes Port Forward

```bash
helm install challenge-devops \
deploy/helm/challenge-devops \
-n challenge-devops
```

This command exposes the Kubernetes service locally, allowing access to the FastAPI application and Prometheus metrics without requiring an ingress controller.

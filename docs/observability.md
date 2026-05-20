# Observability

## Prometheus Metrics

The application exposes Prometheus metrics through the `/metrics` endpoint in `app/api/routes.py`.

The primary metric is:

- `app_requests_total`: total request count for the `/` endpoint.

The metrics implementation lives in `app/observability/metrics.py`.

## Prometheus Configuration

The scrape configuration is defined in `monitoring/prometheus/prometheus.yml`.

The configured job is:

- `job_name: challenge-devops`
- `metrics_path: /metrics`
- `static_configs` with `targets: [172.17.0.1:8082]`

The current Prometheus target uses local Docker bridge networking
to access the Kubernetes port-forwarded application endpoint during local validation.

## Observability Flow

```mermaid
flowchart LR
    Client[HTTP Client] --> FastAPI[FastAPI Application]

    FastAPI --> Metrics[/metrics Endpoint]

    Metrics --> Prometheus[Prometheus Scraping]

    Prometheus --> Grafana[Grafana Dashboard]

    FastAPI --> Logs[Structured JSON Logs]
```

### Note

The current target does not directly match the Kubernetes service defined in the project and should be adjusted to the actual application endpoint or service discovery mechanism.

## Grafana Dashboard

The Grafana dashboard is versioned in `monitoring/grafana/dashboards/challenge-devops-observability-dashboard.json` and can be imported manually into Grafana environments.

The dashboard includes panels for:

- HTTP requests (`app_requests_total`)
- Open file descriptors (`process_open_fds`)
- CPU and memory runtime metrics

Grafana uses Prometheus as its primary datasource to visualize application and runtime metrics, including HTTP requests, CPU usage, memory consumption, and process-level telemetry.

## Logging

The project uses `structlog` in `app/observability/logging.py` to produce structured JSON logs.

Structured logs are emitted during request handling to support operational visibility and troubleshooting.

## Deployment Observability

Future improvements for a production-grade observability stack may include:

- align the Prometheus target with the actual application service;
- provision the Grafana dashboard automatically;
- add additional metrics for latency, error rates, and environment health as the application scales.

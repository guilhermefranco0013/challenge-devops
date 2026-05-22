# Architecture

## Visão geral do projeto

O projeto foi organizado para separar claramente responsabilidades:

- `app/main.py`: inicializa o FastAPI
- `app/api/routes.py`: define rotas públicas e métricas
- `app/core/config.py`: configura ambiente e variáveis
- `app/observability/`: contém logging e métricas
- `deploy/`: contém Docker, Compose, Kubernetes e Helm
- `monitoring/`: contém Prometheus e Grafana

## Fluxo arquitetural

1. O cliente faz requisição HTTP
2. FastAPI despacha para `app/api/routes.py`
3. O endpoint atualiza métricas e registra logs estruturados
4. Métricas são expostas em `/metrics`
5. Prometheus coleta essas métricas
6. Grafana exibe os dashboards versionados

```mermaid
flowchart LR
  Client[HTTP Client] -->|GET /, /health, /metrics| FastAPI[FastAPI Application]
  FastAPI -->|Routes| Routes[app/api/routes.py]
  Routes -->|Log| Logger[structlog JSON Logs]
  Routes -->|Metric| Metrics[app/observability/metrics.py]
  Metrics -->|Expose| MetricsEndpoint[/metrics]
  MetricsEndpoint -->|Scrape| Prometheus[Prometheus]
  Prometheus -->|Visualize| Grafana[Grafana Dashboard]
```

## Padrões de código e qualidade

O projeto agora inclui um `Makefile` para padronizar tarefas e reduzir comandos manuais.

### Exemplos de targets relevantes

```makefile
dev-setup:
	cd app && python3 -m venv .venv
	app/.venv/bin/pip install ruff black pre-commit

lint:
  app/.venv/bin/ruff check app app/tests

fmt:
	app/.venv/bin/black app
```

### Ferramentas adicionadas

- `black`: formatação consistente de código Python
- `ruff`: análise estática e lint rápido
- `pre-commit`: execução de hooks antes do commit

### Exemplo de configuração de hooks

```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 24.11.0
    hooks:
      - id: black

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.0.261
    hooks:
      - id: ruff
        args: ["check", "app", "app/tests"]
```

## Observabilidade

A arquitetura de observabilidade é apoiada por métricas e logs estruturados.

- `app/observability/logging.py`: configura `structlog`
- `app/observability/metrics.py`: define métricas Prometheus

O endpoint `/metrics` é exposto pela rota:

```python
@router.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type="text/plain")
```

## Atualizações recentes

A documentação agora cobre:
- execução local usando `make run`
- qualidade de código com `make lint` e `make fmt`
- deployment com `make docker-build`, `make compose-up`, `make k8s-apply` e `make helm-install`
- port-forward Kubernetes com `make k8s-port-forward`

Isso transforma o repositório em um ambiente mais profissional para review e entrega.

# Terraform Module: observability

## Objetivo

Provisionar e gerenciar a stack de observabilidade da plataforma através do Terraform, utilizando o Helm Provider.

---

## Arquitetura

```text
Terraform
│
├── Helm Provider
│
├── helm_release.prometheus
│       └── Chart: prometheus (prometheus-community)
│
├── helm_release.grafana
│       └── Chart: grafana (grafana)
│
├── helm_release.tempo
│       └── Chart: tempo (grafana)
│
└── helm_release.otel_collector
        └── Chart: opentelemetry-collector (open-telemetry)
```

---

## Componentes Gerenciados

| Componente | Chart | Repositório | Recurso Terraform |
|---|---|---|---|
| **Prometheus** | `prometheus` | `prometheus-community` | `helm_release.prometheus` |
| **Grafana** | `grafana` | `grafana` | `helm_release.grafana` |
| **Tempo** | `tempo` | `grafana` | `helm_release.tempo` |
| **OpenTelemetry Collector** | `opentelemetry-collector` | `open-telemetry` | `helm_release.otel_collector` |

---

## Sprint de Implementação

| Sprint | Descrição | Status |
|---|---|---|
| **Sprint 4 - Observability Foundation** | Criação do módulo, importação das releases existentes, convergência de estado | ✅ Concluída |
| **Sprint 4.1 - Observability Hardening** | Definição de requests/limits para todos os componentes, validação QoS | ✅ Concluída |
| **Sprint 6 - Terraform CI/CD** | Pipeline automatizado com fmt, validate, tflint, checkov, docs, plan, apply | ✅ Concluída |

---

## Entradas (Inputs)

| Nome | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `namespace` | `string` | ✅ | Namespace da stack de observabilidade |
| `prometheus_version` | `string` | ✅ | Versão do chart Prometheus |
| `grafana_version` | `string` | ✅ | Versão do chart Grafana |
| `tempo_version` | `string` | ✅ | Versão do chart Tempo |
| `otel_collector_version` | `string` | ✅ | Versão do chart OpenTelemetry Collector |
| `prometheus_values_file` | `string` | ✅ | Caminho do arquivo values do Prometheus |
| `grafana_values_file` | `string` | ✅ | Caminho do arquivo values do Grafana |
| `tempo_values_file` | `string` | ✅ | Caminho do arquivo values do Tempo |
| `otel_collector_values_file` | `string` | ✅ | Caminho do arquivo values do OTel Collector |

---

## Saídas (Outputs)

| Nome | Descrição |
|---|---|
| `prometheus_release` | Nome da release Helm do Prometheus |
| `grafana_release` | Nome da release Helm do Grafana |
| `tempo_release` | Nome da release Helm do Tempo |
| `otel_collector_release` | Nome da release Helm do OpenTelemetry Collector |

---

## Configuração Atual

| Componente | Chart Version | Arquivo Values |
|---|---|---|
| Prometheus | `29.9.0` | `deploy/observability/prometheus-values.yaml` |
| Grafana | `10.5.15` | `deploy/observability/grafana-values.yaml` |
| Tempo | `1.24.4` | `deploy/observability/tempo-values.yaml` |
| OpenTelemetry Collector | `0.158.0` | `deploy/observability/otel-values.yaml` |

---

## QoS (Quality of Service)

Após o hardening da Sprint 4.1, todos os componentes operam em modo **Burstable**:

| Componente | QoS |
|---|---|
| Grafana | Burstable |
| Prometheus | Burstable |
| Tempo | Burstable |
| OpenTelemetry Collector | Burstable |

> **Lições aprendidas:**
> - Tempo 1.24.4 exige configuração via `tempo.resources`
> - Prometheus Server tem 2 containers no mesmo pod (prometheus-server e prometheus-server-configmap-reload), o que impacta o cálculo total de recursos

---

## Exemplo de Uso

```hcl
module "observability" {
  source = "../../modules/observability"

  namespace = "observability"

  prometheus_version     = "29.9.0"
  grafana_version        = "10.5.15"
  tempo_version          = "1.24.4"
  otel_collector_version = "0.158.0"

  prometheus_values_file     = "../../deploy/observability/prometheus-values.yaml"
  grafana_values_file        = "../../deploy/observability/grafana-values.yaml"
  tempo_values_file          = "../../deploy/observability/tempo-values.yaml"
  otel_collector_values_file = "../../deploy/observability/otel-values.yaml"
}
```

---

## Dependências

Este módulo depende de:

1. **Namespace `observability`** — criado pelo módulo `namespace`
2. **Governança** — ResourceQuota + LimitRange aplicados pelo módulo `governance`
3. **Traefik** — Ingress para acesso externo ao Grafana e Prometheus

No environment `observability`, essas dependências são garantidas via `depends_on`:

```hcl
depends_on = [
  module.observability_namespace,
  module.observability_governance
]
```

---

## Validações no Pipeline CI/CD

Este módulo é validado pelo pipeline `terraform-ci.yml`:

| Etapa | Ferramenta | Comando |
|---|---|---|
| Formatação | `terraform fmt -check` | `terraform fmt -check terraform/modules/observability/` |
| Validação | `terraform validate` | `terraform validate terraform/modules/observability/` |
| Lint | `tflint` | `tflint --config=terraform/.tflint.hcl terraform/modules/observability/` |
| Segurança IaC | `checkov` | `checkov -d terraform/modules/observability/` |

---

## Estratégia de Migração

As releases existentes foram importadas para o Terraform State seguindo o fluxo:

```bash
# Importar releases existentes
terraform import helm_release.prometheus observability/prometheus
terraform import helm_release.grafana observability/grafana
terraform import helm_release.tempo observability/tempo
terraform import helm_release.otel_collector observability/otel-collector

# Validar convergência
terraform plan
terraform apply
terraform plan  # Deve retornar "No changes"
```

---

## Responsabilidade

**Este módulo é responsável por:**
- Prometheus (métricas)
- Grafana (dashboards)
- Tempo (tracing)
- OpenTelemetry Collector (telemetria)

**Não é responsabilidade deste módulo:**
- Namespace (módulo `namespace`)
- ResourceQuota/LimitRange (módulo `governance`)
- NetworkPolicies (módulo `security`)
- Aplicação (Helm)
- Loki/Promtail (futuro)

---

## Evolução Futura

| Componente | Sprint | Status |
|---|---|---|
| Loki | Futuro | 📋 Planejado |
| Promtail | Futuro | 📋 Planejado |

---

## Providers

| Provider | Versão |
|---|---|
| `hashicorp/helm` | `~> 2.14` |

---

## ADRs Relacionadas

- **ADR-001**: Terraform como ferramenta oficial de IaC
- **ADR-005**: Observabilidade instalada via Helm Provider do Terraform
- **ADR-007**: Validação de convergência (No changes)

---

## Roadmap Futuro

| Sprint | Descrição | Status |
|---|---|---|
| **Sprint 7 - GitOps Foundation** | ArgoCD, Application of Applications, Sync Policies | 📋 Planejada |
| **Sprint 8 - Cloud Foundation AWS** | S3 Backend, DynamoDB Locking, VPC, EKS | 📋 Planejada |
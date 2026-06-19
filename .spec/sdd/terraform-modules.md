# Terraform Modules

Este documento descreve os módulos Terraform utilizados pela plataforma challenge-devops.

Cada módulo possui responsabilidade única e ownership claramente definido, seguindo os princípios arquiteturais da plataforma.

---

## Visão Geral

| Módulo | Provider | Responsabilidade | Status |
|---|---|---|---|
| [namespace](#module-namespace) | kubernetes | Namespace, Labels, Annotations | ✅ |
| [governance](#module-governance) | kubernetes | ResourceQuota, LimitRange | ✅ |
| [security](#module-security) | kubernetes | NetworkPolicies, GHCR Pull Secret | ✅ |
| [platform](#module-platform) | helm | Traefik (Ingress Controller) | ✅ |
| [observability](#module-observability) | helm | Prometheus, Grafana, Tempo, OTel Collector | ✅ |

---

## Module: Namespace

Responsável pelo gerenciamento de namespaces Kubernetes.

### Recursos Gerenciados

| Recurso | Tipo |
|---|---|
| `kubernetes_namespace.this` | Namespace |
| metadata.labels | map(string) |
| metadata.annotations | map(string) |

### Entradas

| Nome | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `namespace_name` | string | ✅ | Nome do namespace |
| `labels` | map(string) | ✅ | Labels para organização |
| `annotations` | map(string) | ❌ | Annotations para metadados (default: {}) |

### Saídas

| Nome | Descrição |
|---|---|
| `namespace_name` | Nome do namespace criado |
| `namespace_uid` | UID do namespace criado |

### Dependências

Nenhuma.

### Ownership

Terraform

---

## Module: Governance

Responsável pela governança de recursos dos namespaces Kubernetes.

### Recursos Gerenciados

| Recurso | Tipo |
|---|---|
| `kubernetes_resource_quota.this` | ResourceQuota |
| `kubernetes_limit_range.this` | LimitRange |

### Entradas

| Nome | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `namespace` | string | ✅ | Namespace alvo |
| `requests_cpu` | string | ✅ | CPU total reservada |
| `requests_memory` | string | ✅ | Memória total reservada |
| `limits_cpu` | string | ✅ | Limite máximo de CPU |
| `limits_memory` | string | ✅ | Limite máximo de memória |
| `default_cpu` | string | ✅ | CPU padrão por container |
| `default_memory` | string | ✅ | Memória padrão por container |
| `max_cpu` | string | ✅ | CPU máxima por container |
| `max_memory` | string | ✅ | Memória máxima por container |

### Saídas

| Nome | Descrição |
|---|---|
| `resource_quota_name` | Nome do ResourceQuota criado |
| `limit_range_name` | Nome do LimitRange criado |

### Dependências

- Namespace Module

### Ownership

Terraform

---

## Module: Security

Responsável pelos controles de segurança da plataforma.

### Recursos Gerenciados

| Recurso | Tipo | Descrição |
|---|---|---|
| `default-deny-ingress` | NetworkPolicy | Bloqueia todo tráfego de entrada |
| `default-deny-egress` | NetworkPolicy | Bloqueia todo tráfego de saída |
| `allow-dns-egress` | NetworkPolicy | DNS (53/UDP → kube-system) |
| `allow-ingress-from-traefik` | NetworkPolicy | Traefik (8000/TCP → namespace traefik) |
| `allow-ingress-from-prometheus` | NetworkPolicy | Prometheus (8000/TCP → observability) |
| `allow-egress-to-otel` | NetworkPolicy | OTel (4317,4318/TCP → observability) |
| `ghcr-pull-secret` | Secret (dockerconfigjson) | GHCR authentication |

### Entradas

| Nome | Tipo | Default | Descrição |
|---|---|---|---|
| `namespace` | string | — | Namespace alvo |
| `enable_default_deny_ingress` | bool | true | Default Deny Ingress |
| `enable_default_deny_egress` | bool | true | Default Deny Egress |
| `enable_allow_dns_egress` | bool | true | Allow DNS |
| `enable_allow_ingress_from_traefik` | bool | true | Allow Traefik |
| `enable_allow_ingress_from_prometheus` | bool | false | Allow Prometheus |
| `enable_allow_egress_to_otel` | bool | false | Allow OTel |
| `enable_ghcr_secret` | bool | false | GHCR Pull Secret |
| `ghcr_registry_server` | string | "ghcr.io" | GHCR registry |
| `ghcr_username` | string | "" | GHCR username |
| `ghcr_password` | string (sensitive) | "" | GHCR token |

### Saídas

| Nome | Descrição |
|---|---|
| `namespace` | Namespace gerenciado |
| `ghcr_secret_name` | Nome do GHCR Pull Secret |
| `default_deny_ingress_name` | Nome da política Default Deny Ingress |
| `default_deny_egress_name` | Nome da política Default Deny Egress |
| `allow_dns_egress_name` | Nome da política Allow DNS |
| `allow_traefik_ingress_name` | Nome da política Allow Traefik |
| `allow_prometheus_ingress_name` | Nome da política Allow Prometheus |
| `allow_otel_egress_name` | Nome da política Allow OTel |

### Dependências

- Namespace Module (namespace alvo deve existir)

### Ownership

Terraform

---

## Module: Platform

Responsável pelos componentes compartilhados da plataforma Kubernetes.

### Recursos Gerenciados

| Recurso | Tipo |
|---|---|
| `helm_release.traefik` | Helm Release |

### Entradas

| Nome | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `namespace` | string | ✅ | Namespace de instalação |
| `traefik_chart_version` | string | ✅ | Versão do chart (atual: 40.2.0) |
| `replicas` | number | ✅ | Réplicas (atual: 1) |
| `web_node_port` | number | ✅ | NodePort HTTP (atual: 30080) |
| `websecure_node_port` | number | ✅ | NodePort HTTPS (atual: 30443) |
| `node_selector_role` | string | ✅ | Label para node selector (atual: platform-observability) |

### Saídas

| Nome | Descrição |
|---|---|
| `traefik_release` | Nome da release Helm do Traefik |

### Dependências

- Namespace Module
- Governance Module

### Ownership

Terraform

---

## Module: Observability

Responsável pela stack de observabilidade da plataforma.

### Recursos Gerenciados

| Recurso | Chart | Repositório |
|---|---|---|
| `helm_release.prometheus` | prometheus (29.9.0) | prometheus-community |
| `helm_release.grafana` | grafana (10.5.15) | grafana |
| `helm_release.tempo` | tempo (1.24.4) | grafana |
| `helm_release.otel_collector` | opentelemetry-collector (0.158.0) | open-telemetry |

### Entradas

| Nome | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `namespace` | string | ✅ | Namespace da stack |
| `prometheus_version` | string | ✅ | Versão do chart Prometheus |
| `grafana_version` | string | ✅ | Versão do chart Grafana |
| `tempo_version` | string | ✅ | Versão do chart Tempo |
| `otel_collector_version` | string | ✅ | Versão do chart OTel Collector |
| `prometheus_values_file` | string | ✅ | Caminho do values file |
| `grafana_values_file` | string | ✅ | Caminho do values file |
| `tempo_values_file` | string | ✅ | Caminho do values file |
| `otel_collector_values_file` | string | ✅ | Caminho do values file |

### Saídas

| Nome | Descrição |
|---|---|
| `prometheus_release` | Nome da release Helm do Prometheus |
| `grafana_release` | Nome da release Helm do Grafana |
| `tempo_release` | Nome da release Helm do Tempo |
| `otel_collector_release` | Nome da release Helm do OTel Collector |

### Dependências

- Namespace Module
- Governance Module

### Evoluções Futuras

- Loki
- Promtail

### Ownership

Terraform

---

## Princípios

Todos os módulos seguem os seguintes princípios:

1. Responsabilidade única.
2. Reutilização entre ambientes.
3. Infraestrutura definida como código.
4. Ownership exclusivo por componente.
5. Alterações auditáveis através de versionamento.
6. Terraform como única fonte de verdade para recursos de infraestrutura.

Nenhum recurso pode possuir múltiplos responsáveis.

A separação de responsabilidades é definida pelos documentos de arquitetura, ADRs e boundaries da plataforma.

---

## Estrutura de Arquivos

Todo módulo deve conter:

```text
terraform/modules/<module-name>/
├── main.tf          # Recursos do módulo
├── variables.tf     # Variáveis de entrada
├── outputs.tf       # Saídas do módulo
├── versions.tf      # Versões do Terraform e providers
└── README.md        # Documentação completa
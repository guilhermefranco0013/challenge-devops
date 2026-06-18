# Terraform Modules

Este documento descreve os módulos Terraform utilizados pela plataforma challenge-devops.

Cada módulo possui responsabilidade única e ownership claramente definido, seguindo os princípios arquiteturais da plataforma.

---

# Module: Namespace

Responsável pelo gerenciamento de namespaces Kubernetes.

## Recursos Gerenciados

* Namespace
* Labels
* Annotations

## Entradas

* namespace_name
* labels
* annotations

## Saídas

* namespace_name
* namespace_uid

## Ownership

Terraform

---

# Module: Governance

Responsável pela governança de recursos dos namespaces Kubernetes.

## Recursos Gerenciados

* ResourceQuota
* LimitRange

## Entradas

* namespace
* requests_cpu
* requests_memory
* limits_cpu
* limits_memory
* default_cpu
* default_memory
* max_cpu
* max_memory

## Saídas

* resource_quota_name
* limit_range_name

## Dependências

* Namespace Module

## Ownership

Terraform

---

# Module: Security

Responsável pelos controles básicos de segurança da plataforma.

## Recursos Gerenciados

* NetworkPolicies (Default Deny + Allow Rules)
* GHCR Pull Secret

### NetworkPolicies

* default-deny-ingress - Bloqueia todo tráfego de entrada por padrão
* default-deny-egress - Bloqueia todo tráfego de saída por padrão
* allow-dns-egress - Permite resolução DNS (porta 53 UDP → kube-system)
* allow-ingress-from-traefik - Permite tráfego HTTP do Traefik (porta 8000 TCP)
* allow-ingress-from-prometheus - Permite scraping do Prometheus (porta 8000 TCP)
* allow-egress-to-otel - Permite envio de telemetria ao OTel (portas 4317/4318 TCP)

### GHCR Pull Secret

* ghcr-pull-secret - Secret tipo docker-registry para autenticação no GHCR

## Entradas

* namespace
* enable_default_deny_ingress (bool, default: true)
* enable_default_deny_egress (bool, default: true)
* enable_allow_dns_egress (bool, default: true)
* enable_allow_ingress_from_traefik (bool, default: true)
* enable_allow_ingress_from_prometheus (bool, default: false)
* enable_allow_egress_to_otel (bool, default: false)
* enable_ghcr_secret (bool, default: false)
* ghcr_registry_server (string, default: "ghcr.io")
* ghcr_username (string)
* ghcr_password (string, sensitive)

## Saídas

* namespace
* ghcr_secret_name
* default_deny_ingress_name
* default_deny_egress_name
* allow_dns_egress_name
* allow_traefik_ingress_name
* allow_prometheus_ingress_name
* allow_otel_egress_name

## Dependências

* Namespace Module

## Ownership

Terraform

---

# Module: Platform

Responsável pelos componentes compartilhados da plataforma Kubernetes.

## Recursos Gerenciados

* Traefik
* Ingress Controller
* Routing Layer

## Entradas

* namespace
* traefik_chart_version
* replicas
* web_node_port
* websecure_node_port
* node_selector_role

## Saídas

* traefik_release

## Dependências

* Namespace Module
* Governance Module

## Ownership

Terraform

---

# Module: Observability

Responsável pela stack de observabilidade da plataforma.

## Recursos Gerenciados

* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector

## Entradas

* namespace
* prometheus_version
* grafana_version
* tempo_version
* otel_collector_version
* prometheus_values_file
* grafana_values_file
* tempo_values_file
* otel_collector_values_file

## Saídas

* prometheus_release
* grafana_release
* tempo_release
* otel_collector_release

## Dependências

* Namespace Module
* Governance Module

## Ownership

Terraform

## Evoluções Futuras

* Loki
* Promtail

---

# Princípios

Todos os módulos seguem os seguintes princípios:

1. Responsabilidade única.
2. Reutilização entre ambientes.
3. Infraestrutura definida como código.
4. Ownership exclusivo por componente.
5. Alterações auditáveis através de versionamento.
6. Terraform como única fonte de verdade para recursos de infraestrutura.

Nenhum recurso pode possuir múltiplos responsáveis.

A separação de responsabilidades é definida pelos documentos de arquitetura, ADRs e boundaries da plataforma.
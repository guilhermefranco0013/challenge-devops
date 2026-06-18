# Platform Architecture

## Objetivo

Definir a arquitetura oficial da plataforma challenge-devops após a introdução do Terraform como camada de Infrastructure as Code.

Este documento consolida responsabilidades, componentes da plataforma, namespaces e limites arquiteturais entre Terraform, Helm e GitHub Actions.

---

# Arquitetura Geral

A plataforma é composta por três camadas principais:

```text
Terraform
↓
Provisionamento da Infraestrutura da Plataforma

Helm
↓
Deployment da Aplicação

GitHub Actions
↓
CI/CD e DevSecOps
```

Cada recurso possui um único responsável.

Nenhum recurso poderá ser gerenciado simultaneamente por mais de uma ferramenta.

---

# Cluster Kubernetes (Kind)

O cluster Kind já está provisionado e operacional.

Responsável pelos nodes, labels e port mappings utilizados pela plataforma.

Configuração atual:

```yaml
# deploy/kind/cluster.yml
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080  → hostPort: 80
  - containerPort: 30443  → hostPort: 443
- role: worker
  labels:
    role: platform-app
- role: worker
  labels:
    role: platform-observability
```

Atualmente provisionado via comando local (`kind create cluster --config deploy/kind/cluster.yml`).

Evolução futura: gerenciamento via Terraform (terraform/bootstrap/).

---

# Terraform

Responsável pelo provisionamento e gerenciamento da infraestrutura da plataforma no cluster Kubernetes.

## Escopo Atual

* Namespaces
* ResourceQuotas
* LimitRanges
* NetworkPolicies
* GHCR Pull Secrets
* Traefik (Ingress Controller)
* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector

## Escopo Futuro

* Cluster Kind (via bootstrap)
* Loki
* Promtail

Terraform é a única fonte de verdade da plataforma.

---

# Helm

Responsável exclusivamente pelos recursos da aplicação.

## Escopo

* Deployment
* Service
* ConfigMap
* Secret
* IngressRoute
* HPA (futuro)
* PDB (futuro)

Helm não é responsável por componentes da plataforma.

---

# GitHub Actions

Responsável pelos processos de integração contínua, segurança e entrega.

## CI

* Ruff
* Black
* Isort
* Pytest

## Security

* Trivy
* SBOM
* Cosign
* SARIF

## Delivery

* Build
* Push
* Promoção DEV → HML → PROD
* Helm Deploy
* Health Checks

GitHub Actions não cria infraestrutura.

---

# Namespaces

## Aplicação

```text
dev
hml
prod
```

Responsáveis pelo deployment da aplicação FastAPI.
Gerenciados pelo Terraform via módulo namespace.

---

## Plataforma

### Namespace: observability

Responsável por:

* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector
* Loki (futuro)
* Promtail (futuro)

### Namespace: traefik

Responsável por:

* Traefik Ingress Controller
* Routing Layer
* Ingress Traffic Management

---

# Estrutura Terraform

```text
terraform/
├── bootstrap/                       (futuro - cluster Kind via Terraform)
├── environments/
│   ├── dev/                         (namespace + governance)
│   ├── hml/                         (namespace + governance)
│   ├── prod/                        (namespace + governance)
│   ├── observability/               (namespace + governance + stack observability)
│   ├── traefik/                     (namespace + governance + Traefik)
│   └── security/                    (NetworkPolicies + GHCR Secret)
└── modules/
    ├── namespace/                   (Namespace, Labels, Annotations)
    ├── governance/                  (ResourceQuota, LimitRange)
    ├── security/                    (NetworkPolicies, GHCR Pull Secret)
    ├── observability/               (Prometheus, Grafana, Tempo, OTel)
    └── platform/                    (Traefik)
```

---

# Responsabilidades dos Módulos

## namespace

Responsável por:

* Namespace
* Labels
* Annotations

---

## governance

Responsável por:

* ResourceQuota
* LimitRange

---

## security

Responsável por:

* NetworkPolicies (Default Deny + Allow Rules)
* GHCR Pull Secret

Recursos:

* default-deny-ingress
* default-deny-egress
* allow-dns-egress
* allow-ingress-from-traefik
* allow-ingress-from-prometheus
* allow-egress-to-otel
* ghcr-pull-secret

---

## observability

Responsável por:

* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector

Evolução futura:

* Loki
* Promtail

Namespace alvo:

```text
observability
```

---

## platform

Responsável por:

* Traefik
* Routing Layer
* Componentes compartilhados de acesso

Namespace alvo:

```text
traefik
```

---

# Princípios Arquiteturais

1. Terraform provisiona infraestrutura da plataforma.
2. Helm entrega aplicações.
3. GitHub Actions orquestra pipelines.
4. Infrastructure as Code é a única fonte de verdade.
5. Toda infraestrutura deve ser reproduzível.
6. Toda alteração deve ser auditável.
7. Nenhum recurso possui múltiplos responsáveis.
8. Toda plataforma deve ser reconstruível através de código.

---

# Roadmap Terraform

## Sprint 1 — Foundation

* Providers
* Namespaces

## Sprint 2 — Governance

* ResourceQuota
* LimitRange

## Sprint 3 — Platform

* Traefik

## Sprint 4 — Observability

* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector

## Sprint 5 — Security

* NetworkPolicies (Default Deny + Allow Rules)
* GHCR Pull Secret

## Sprint 6 — Terraform CI/CD

* terraform fmt
* terraform validate
* tflint
* checkov
* terraform-docs
* terraform plan
* terraform apply

## Futuro — Cluster Kind + AWS

* bootstrap/ (cluster Kind via Terraform)
* VPC, Security Groups, IAM, EC2
* S3 Backend, Remote State, DynamoDB Locking
# Architecture Decision Records (ADRs)

Este documento registra as decisões arquiteturais (ADRs) do projeto challenge-devops.

Cada ADR representa uma decisão relevante sobre a arquitetura, ferramentas ou processos da plataforma.

---

| ADR | Título | Status |
|---|---|---|
| ADR-001 | Terraform será a ferramenta oficial de Infrastructure as Code | ✅ Accepted |
| ADR-002 | Helm continuará sendo utilizado para deployment de aplicações | ✅ Accepted |
| ADR-003 | GitHub Actions continuará sendo o orquestrador de CI/CD | ✅ Accepted |
| ADR-004 | Terraform utilizará módulos reutilizáveis | ✅ Accepted |
| ADR-005 | Observabilidade será instalada via Helm Provider do Terraform | ✅ Accepted |
| ADR-006 | Namespaces serão gerenciados exclusivamente pelo Terraform | ✅ Accepted |
| ADR-007 | Stack de observabilidade gerenciada exclusivamente pelo Terraform via Helm Provider | ✅ Accepted |

---

## ADR-001: Terraform como IaC oficial

**Decisão:** Terraform será a ferramenta oficial de Infrastructure as Code.

**Contexto:** A plataforma dependia de configurações manuais para recursos compartilhados (namespaces, ingress, observabilidade).

**Consequências:**
- Toda infraestrutura compartilhada da plataforma será gerenciada pelo Terraform
- Terraform é a única fonte de verdade
- Módulos reutilizáveis entre ambientes

**Status:** Accepted ✅

---

## ADR-002: Helm para deployment de aplicações

**Decisão:** Helm continuará sendo utilizado para deployment de aplicações.

**Contexto:** A aplicação FastAPI já era entregue via Helm. A introdução do Terraform não altera essa responsabilidade.

**Consequências:**
- Helm gerencia Deployment, Service, ConfigMap, Secret, IngressRoute
- Terraform gerencia infraestrutura compartilhada
- Separação clara de responsabilidades

**Status:** Accepted ✅

---

## ADR-003: GitHub Actions como orquestrador de CI/CD

**Decisão:** GitHub Actions continuará sendo o orquestrador de CI/CD.

**Contexto:** Os pipelines de CI/CD já estavam implementados com GitHub Actions.

**Consequências:**
- CI: Ruff, Black, Isort, Pytest
- Quality: terraform fmt, validate, tflint, terraform-docs
- Security: Trivy, SBOM, Cosign, SARIF, Checkov
- Delivery: Build, Push, Promotion, Helm Deploy

**Status:** Accepted ✅

---

## ADR-004: Módulos Terraform reutilizáveis

**Decisão:** Terraform utilizará módulos reutilizáveis.

**Contexto:** Múltiplos ambientes (DEV, HML, PROD, OBSERVABILITY, TRAEFIK) compartilham a mesma estrutura de recursos.

**Consequências:**
- Cada módulo tem responsabilidade única
- Módulos são versionados e reutilizados entre ambientes
- Redução de duplicação de código

**Status:** Accepted ✅

---

## ADR-005: Observabilidade via Helm Provider do Terraform

**Decisão:** Observabilidade será instalada através do Helm Provider do Terraform.

**Contexto:** A stack de observabilidade (Prometheus, Grafana, Tempo, OTel) era gerenciada manualmente via Helm CLI.

**Consequências:**
- Terraform gerencia as releases Helm da stack
- Values files permanecem versionados em `deploy/observability/`
- Upgrades controlados e auditáveis

**Status:** Accepted ✅

---

## ADR-006: Namespaces gerenciados pelo Terraform

**Decisão:** Namespaces serão gerenciados exclusivamente pelo Terraform.

**Contexto:** Namespaces eram criados manualmente ou via Helm `--create-namespace`.

**Consequências:**
- Módulo `namespace` criado
- 5 namespaces gerenciados: dev, hml, prod, observability, traefik
- Labels e annotations padronizadas

**Status:** Accepted ✅

---

## ADR-007: Observabilidade gerenciada exclusivamente pelo Terraform

**Decisão:** A stack de observabilidade será gerenciada exclusivamente pelo Terraform utilizando o Helm Provider.

**Validação (Sprint 4):**
- `terraform state list` contém todas as releases Helm da stack
- `terraform plan` converge para "No changes"
- Nenhuma release é gerenciada manualmente via Helm
- Terraform é a única fonte de verdade da stack de observabilidade

**Status:** Accepted ✅
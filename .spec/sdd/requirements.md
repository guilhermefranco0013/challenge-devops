# Requirements

## Objetivo

Definir os requisitos funcionais e não funcionais da introdução do Terraform no projeto challenge-devops.

---

## Requisitos Funcionais

| ID | Descrição | Status |
|---|---|---|
| RF-001 | O cluster Kubernetes deve ser provisionado através de Infrastructure as Code. | ✅ Atendido (Kind via comando local, bootstrap Terraform futuro) |
| RF-002 | Namespaces DEV, HML, PROD, OBSERVABILITY e TRAEFIK devem ser criados automaticamente. | ✅ Atendido (módulo namespace) |
| RF-003 | A plataforma de observabilidade deve ser instalada automaticamente (Prometheus, Grafana, Tempo, OTel Collector). | ✅ Atendido (módulo observability via Helm Provider) |
| RF-004 | Traefik deve ser provisionado automaticamente. | ✅ Atendido (módulo platform via Helm Provider) |
| RF-005 | ResourceQuotas devem existir para todos os namespaces. | ✅ Atendido (módulo governance) |
| RF-006 | LimitRanges devem existir para todos os namespaces. | ✅ Atendido (módulo governance) |
| RF-007 | NetworkPolicies devem existir para todos os namespaces. | ✅ Atendido (módulo security) |
| RF-008 | GitHub Actions não deve criar infraestrutura. | ✅ Atendido |
| RF-009 | Helm não deve criar infraestrutura. | ✅ Atendido |
| RF-010 | Terraform deve ser a única fonte de verdade da plataforma. | ✅ Atendido |
| RF-011 | GHCR Pull Secret deve ser gerenciado pelo Terraform para autenticação em registry privado. | ✅ Atendido (módulo security, ativo com credenciais) |
| RF-012 | Validações de qualidade Terraform (fmt, validate, tflint, checkov) devem ser automatizadas no CI. | ✅ Atendido (Sprint 6, pipeline terraform-ci.yml) |

---

## Requisitos Não Funcionais

| ID | Descrição | Status |
|---|---|---|
| RNF-001 | Infraestrutura deve ser reproduzível. | ✅ Atendido (código versionado, módulos reutilizáveis) |
| RNF-002 | Infraestrutura deve ser idempotente. | ✅ Atendido (Terraform garante idempotência) |
| RNF-003 | Infraestrutura deve ser modular. | ✅ Atendido (5 módulos com responsabilidade única) |
| RNF-004 | Infraestrutura deve ser versionada. | ✅ Atendido (Git + Terraform State) |
| RNF-005 | Infraestrutura deve suportar múltiplos ambientes. | ✅ Atendido (DEV, HML, PROD, OBSERVABILITY, TRAEFIK) |

---

## Observações Técnicas

### OBS-004: Requests e Limits em Observabilidade

Todos os componentes da stack de observabilidade devem definir explicitamente requests e limits de CPU e memória.

**Critério de Aceitação:**
- Prometheus possui requests e limits ✅
- Grafana possui requests e limits ✅
- Tempo possui requests e limits ✅
- OpenTelemetry Collector possui requests e limits ✅
- ResourceQuota contabiliza consumo de recursos ✅

**QoS Resultante:**
| Componente | QoS |
|---|---|
| Grafana | Burstable |
| Prometheus | Burstable |
| Tempo | Burstable |
| OpenTelemetry Collector | Burstable |

### OBS-005: Pipeline Terraform CI/CD

Pipeline automatizado no arquivo `.github/workflows/terraform-ci.yml` executa:
- `terraform fmt -check`
- `terraform validate`
- `tflint`
- `checkov` + SARIF Upload
- `terraform-docs`
- `terraform plan`
- `terraform apply`

### OBS-006: GHCR Pull Secret

- Implementado no módulo `security`
- Auto-ativação via `local.ghcr_configured` (username + password não vazios)
- Credenciais configuradas em `terraform/environments/security/terraform.tfvars`
- Em CI/CD, injetadas via variáveis `TF_VAR_ghcr_username` e `TF_VAR_ghcr_password`
- Secret: `ghcr-pull-secret` nos namespaces DEV, HML, PROD
# Terraform Roadmap

## Objetivo

Definir a evolução da camada Terraform do projeto challenge-devops, garantindo que toda a infraestrutura da plataforma seja provisionada e gerenciada através de Infrastructure as Code.

---

# Sprint 1 - Foundation ✅

## Objetivo

Estabelecer a base da estrutura Terraform e iniciar o gerenciamento dos namespaces Kubernetes.

## Pré-requisito - Cluster Kind

O cluster Kind já está provisionado e operacional com a configuração definida em `deploy/kind/cluster.yml`:

```yaml
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080 → hostPort: 80
  - containerPort: 30443 → hostPort: 443
- role: worker (label: platform-app)
- role: worker (label: platform-observability)
```

Evolução futura: gerenciamento do cluster via Terraform (terraform/bootstrap/).

## Entregas

### Providers
* Kubernetes Provider

### Estrutura Terraform
* bootstrap/ (futuro)
* environments/ (dev, hml, prod, observability, traefik, security)
* modules/ (namespace, governance, platform, observability, security)

### Namespace Module
* Namespace
* Labels
* Annotations

### Namespaces Gerenciados
* DEV ✅
* HML ✅
* PROD ✅
* OBSERVABILITY ✅
* TRAEFIK ✅

## Status: ✅ Concluída

---

# Sprint 2 - Governance ✅

## Objetivo

Implementar governança básica para todos os namespaces da plataforma.

## Entregas

### Governance Module
* ResourceQuota
* LimitRange

### Ambientes Governados
* DEV ✅
* HML ✅
* PROD ✅
* OBSERVABILITY ✅
* TRAEFIK ✅

### Validações
* terraform fmt -recursive
* terraform validate
* terraform plan
* terraform apply
* kubectl get resourcequota -A
* kubectl get limitrange -A

## Status: ✅ Concluída

---

# Sprint 3 - Platform ✅

## Objetivo

Provisionar o Ingress Controller Traefik através do Terraform utilizando o Helm Provider.

## Entregas
* Helm Provider
* Platform Module
* Traefik Helm Release (chart 40.2.0)
* Terraform Import + State Convergence

## Resultado
```text
No changes. Your infrastructure matches the configuration.
```

## Status: ✅ Concluída

---

# Sprint 4 - Observability Foundation ✅

## Objetivo

Provisionar a stack de observabilidade através do Terraform via Helm Provider.

## Entregas

### Observability Module
| Componente | Chart Version |
|---|---|
| Prometheus | 29.9.0 |
| Grafana | 10.5.15 |
| Tempo | 1.24.4 |
| OpenTelemetry Collector | 0.158.0 |

### Estratégia
1. Declarar recursos Terraform
2. Importar releases existentes
3. Validar estado (terraform plan → No changes)
4. Convergir infraestrutura (terraform apply)

## Status: ✅ Concluída

---

# Sprint 4.1 - Observability Hardening ✅

## Objetivo

Adequar a stack de observabilidade às políticas de governança da Sprint 2 através da definição explícita de requests e limits.

## Entregas
* Requests/limits para Prometheus, Grafana, Tempo, OTel Collector
* Validação de ResourceQuota (consumo > 0)
* Validação de QoS

## QoS Resultante

| Componente | QoS |
|---|---|
| Grafana | Burstable |
| Prometheus | Burstable |
| Tempo | Burstable |
| OpenTelemetry Collector | Burstable |

## Lições Aprendidas
- Tempo 1.24.4 exige configuração via `tempo.resources`
- Prometheus Server tem 2 containers no mesmo pod
- ResourceQuota + LimitRange impedem pods incompatíveis

## Status: ✅ Concluída

---

# Sprint 5 - Security ✅

## Objetivo

Implementar controles básicos de segurança da plataforma Kubernetes.

## Sprint 5.1 - Security Foundation ✅
* Criação do módulo security
* Definição de variáveis e outputs
* Estruturação dos recursos de NetworkPolicy

## Sprint 5.2 - Network Segmentation ✅
* Default Deny Ingress + Egress
* Isolamento entre namespaces
* Aplicado em: dev, hml, prod, observability, traefik

**Lição:** Namespace hardcoded ("dev") corrigido para `var.namespace`.

## Sprint 5.3 - Explicit Traffic Allow Rules ✅

| Namespace | DNS | Traefik | Prometheus | OTel |
|---|---|---|---|---|
| dev | ✅ | ✅ | ✅ | ✅ |
| hml | ✅ | ✅ | ✅ | ✅ |
| prod | ✅ | ✅ | ✅ | ✅ |
| observability | ✅ | ✅ | ❌ | ❌ |
| traefik | ✅ | ❌ | ❌ | ❌ |

Variáveis de controle:
- `enable_allow_dns_egress` (default: true)
- `enable_allow_ingress_from_traefik` (default: true)
- `enable_allow_ingress_from_prometheus` (default: false)
- `enable_allow_egress_to_otel` (default: false)

## Sprint 5.4 - Registry Authentication ✅
* GHCR Pull Secret implementado e ATIVO
* Auto-ativação via `local.ghcr_configured`
* Credenciais em `terraform/environments/security/terraform.tfvars`
* CI/CD: variáveis `TF_VAR_ghcr_username` / `TF_VAR_ghcr_password`
* Secret: `ghcr-pull-secret` em DEV, HML, PROD

## Resultado Final da Sprint 5
- Security Module implementado ✅
- NetworkPolicies gerenciadas por Terraform ✅
- Modelo Default Deny aplicado ✅
- Fluxos liberados (DNS, Traefik, Prometheus, OTel) ✅
- GHCR Pull Secret ativo ✅

## Status: ✅ Concluída

---

# Sprint 6 - Terraform CI/CD ✅

## Objetivo

Automatizar validações e execuções Terraform.

## Entregas

### Pipeline (.github/workflows/terraform-ci.yml)
| Etapa | Ferramenta | Finalidade |
|---|---|---|
| Formatação | terraform fmt -check | Qualidade de código |
| Validação | terraform validate | Consistência sintática |
| Lint | tflint | Análise estática |
| Segurança | checkov + SARIF | IaC security scanning |
| Documentação | terraform-docs | Documentação automática |
| Planejamento | terraform plan | Dry-run |
| Aplicação | terraform apply | Provisionamento |

### Configurações
* `terraform/.checkov.yml` — supressão de checks CKV_K8S_* não aplicáveis ao Kind
* `terraform/.tflint.hcl` — preset recommended, regras de qualidade habilitadas

## Status: ✅ Concluída

---

# Sprint 7 - GitOps Foundation 📋

## Objetivo

Implementar GitOps como modelo operacional para gerenciamento do cluster e deployments.

## Escopo Previsto

### ArgoCD
* Instalação do ArgoCD no cluster
* Configuração de projeto

### Estrutura GitOps
* Application of Applications pattern
* Environment Promotion Strategy (DEV → HML → PROD)

### Operação
* Sync Policies (auto-sync, prune, self-heal)
* Drift Detection
* Rollback automático

### Documentação
* GitOps workflow documentation
* Disaster recovery procedures

## Resultado Esperado
Pipeline GitOps operacional com promoção entre ambientes.

## Status: 📋 Planejada

---

# Sprint 8 - Cloud Foundation (AWS) 📋

## Objetivo

Provisionar infraestrutura cloud AWS para hospedar a plataforma.

## Escopo Previsto

### Terraform Backend
* S3 Backend para state remoto
* DynamoDB State Locking

### Providers
* AWS Provider
* Kubernetes Provider
* Helm Provider

### Foundation Resources
* VPC
* Subnets (pública e privada)
* Route Tables
* NAT Gateway
* Security Groups
* IAM Roles

### Container Platform
* ECR (container registry)
* EKS (Kubernetes gerenciado) ou EC2 + Kind

### Data Layer
* RDS PostgreSQL

## Resultado Esperado
Plataforma completamente reproduzível em infraestrutura AWS.

## Status: 📋 Planejada
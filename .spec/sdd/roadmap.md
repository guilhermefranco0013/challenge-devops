# Terraform Roadmap

## Objetivo

Definir a evolução da camada Terraform do projeto challenge-devops, garantindo que toda a infraestrutura da plataforma seja provisionada e gerenciada através de Infrastructure as Code.

---

# Sprint 1 - Foundation

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

Provisionado via: `kind create cluster --config deploy/kind/cluster.yml`

Evolução futura: gerenciamento do cluster via Terraform (terraform/bootstrap/).

## Entregas

### Providers

* Kubernetes Provider

### Estrutura Terraform

* bootstrap/ (futuro - cluster Kind via Terraform)
* environments/
* modules/

### Namespace Module

* Namespace
* Labels
* Annotations

### Namespaces Gerenciados

* DEV
* HML
* PROD
* OBSERVABILITY
* TRAEFIK

## Status

✅ Concluída

---

# Sprint 2 - Governance

## Objetivo

Implementar governança básica para todos os namespaces da plataforma.

## Entregas

### Governance Module

* ResourceQuota
* LimitRange

### Ambientes Governados

* DEV
* HML
* PROD
* OBSERVABILITY
* TRAEFIK

### Validações Executadas

* terraform fmt -recursive
* terraform validate
* terraform plan
* terraform apply
* terraform state list
* kubectl get resourcequota -A
* kubectl get limitrange -A
* kubectl describe resourcequota

## Resultado

Todos os namespaces da plataforma possuem:

* ResourceQuota
* LimitRange

gerenciados através do Terraform.

## Status

✅ Concluída

---

# Sprint 3 - Platform

## Objetivo

Provisionar o Ingress Controller Traefik através do Terraform utilizando o Helm Provider.

## Entregas

* Helm Provider
* Platform Module
* Traefik Helm Release
* Terraform Import
* State Management

Validação Final:

terrafrom plan

Resultado:

No changes.
Your infrastructure matches the configuration.

## Status

✅ Concluída

---

# Sprint 4 - Observability Foundation

## Objetivo

Provisionar a stack de observabilidade através do Terraform.

## Entregas

### Observability Module

* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector

Estratégia:

- Declarar recursos Terraform
- Importar releases existentes
- Validar estado
- Convergir infraestrutura

### Ajustes de Governança

Definição de:

* requests.cpu
* requests.memory
* limits.cpu
* limits.memory

para todos os componentes da stack.

## Resultado Esperado

Terraform passa a ser responsável pela instalação e gerenciamento da observabilidade da plataforma.

## Status

✅ Concluída

---

# Sprint 4.1 - Observability Hardening

## Objetivo

Adequar a stack de observabilidade às políticas de governança
implementadas na Sprint 2 através da definição explícita de
requests e limits para todos os componentes observáveis.

### Entregas

* Requests CPU
* Requests Memory
* Limits CPU
* Limits Memory
* Validação de ResourceQuota
* Validação de Consumo

### Observability Module

* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector

Estratégia:

- Declarar recursos Terraform
- Importar releases existentes
- Validar estado
- Convergir infraestrutura

### Ajustes de Governança

Definição de:

* requests.cpu
* requests.memory
* limits.cpu
* limits.memory

para todos os componentes da stack.

## Resultado Esperado

Deve apresentar consumo diferente de zero para:

kubectl describe resourcequota -n observability

* requests.cpu
* requests.memory
* limits.cpu
* limits.memory

Validação QoS:

* Grafana → Burstable
* Prometheus → Burstable
* Tempo → Burstable
* OpenTelemetry Collector → Burstable

## Status

✅ Concluída

---

# Sprint 5 - Security

## Objetivo

Implementar controles básicos de segurança da plataforma Kubernetes utilizando Terraform como única fonte de verdade para recursos de segurança compartilhados.

## Status

✅ Concluída

---

### Sprint 5.1 - Security Foundation

Objetivo:

Criar a estrutura do módulo Security e estabelecer a base para os controles de segurança da plataforma.

Entregas:

* Criação do módulo security
* Definição das variáveis e outputs
* Estruturação dos recursos de NetworkPolicy
* Preparação para gerenciamento de secrets compartilhados

Validações:

* terraform fmt -recursive
* terraform validate
* terraform plan

## Status

✅ Concluída

---

### Sprint 5.2 - Network Segmentation

Objetivo:

Implementar isolamento de tráfego entre workloads através de NetworkPolicies.

Entregas:

* Default Deny Ingress
* Default Deny Egress
* Isolamento entre namespaces
* Validação do comportamento de bloqueio

Aplicado em:

✅ dev
✅ hml
✅ prod
✅ observability
✅ traefik

Validações:

* kubectl get networkpolicy -A
* kubectl describe networkpolicy
* Testes de conectividade entre namespaces

Resultado Esperado:

Todo tráfego passa a ser negado por padrão.

### Lição aprendida

Durante a implementação inicial das NetworkPolicies
foi identificado um namespace hardcoded ("dev")
no módulo security.

O erro provocou tentativas de criação do mesmo
recurso em múltiplos módulos.

Correção aplicada:

namespace = var.namespace

Resultado:

As policies passaram a ser criadas corretamente
nos namespaces DEV, HML, PROD, OBSERVABILITY e TRAEFIK.

## Status

✅ Concluída

---

### Sprint 5.3 - Explicit Traffic Allow Rules

Objetivo:

Liberar apenas os fluxos necessários para funcionamento da plataforma,
operando sob modelo Zero Trust.

Entregas:

* DNS Allow Rules (porta 53 UDP → kube-system)
* Traefik → Aplicações (porta 8000 TCP)
* Prometheus → Aplicações (porta 8000 TCP, scraping de métricas)
* Aplicações → OpenTelemetry Collector (portas 4317/4318 TCP)

Configuração por namespace:

| Namespace      | DNS |  Traefik | Prometheus  | OTel |
|----------------|-----|----------|-------------|------|
| dev            | ✅  | ✅      | ✅         | ✅   |
| hml            | ✅  | ✅      | ✅         | ✅   |
| prod           | ✅  | ✅      | ✅         | ✅   |
| observability  | ✅  | ✅      | ❌         | ❌   |
| traefik        | ✅  | ❌      | ❌         | ❌   |

Cada regra é controlada por variável booleana independente:

* enable_allow_dns_egress
* enable_allow_ingress_from_traefik
* enable_allow_ingress_from_prometheus (default: false)
* enable_allow_egress_to_otel (default: false)

Validações:

* Testes de acesso via Ingress
* Testes de scraping Prometheus
* Testes de envio de telemetry

Resultado Esperado:

Plataforma funcional operando sob modelo Zero Trust.

## Status

✅ Concluída

---

### Sprint 5.4 - Registry Authentication

Objetivo:

Permitir consumo seguro de imagens privadas armazenadas no GitHub Container Registry.

Entregas:

* GHCR Pull Secret
* Secret gerenciado pelo Terraform
* Integração com workloads Kubernetes
* Padronização para DEV, HML e PROD

O recurso está implementado no módulo security e desabilitado por padrão (`enable_ghcr_secret = false`).
A ativação requer configuração de credenciais GHCR via variáveis.

Variáveis:

* enable_ghcr_secret (bool, default: false)
* ghcr_registry_server (string, default: "ghcr.io")
* ghcr_username (string)
* ghcr_password (string, sensitive)

Validações:

* kubectl get secret -A
* Deploy utilizando imagem privada
* Pull bem-sucedido a partir do GHCR

Resultado Esperado:

Namespaces preparados para consumo de imagens privadas.

## Status

✅ Concluída (aguardando configuração de credenciais GHCR para ativação)

---

### Resultado Final da Sprint 5

Objetivos atingidos:

* Security Module implementado
* NetworkPolicies gerenciadas por Terraform
* Modelo Default Deny aplicado
* Fluxos necessários liberados explicitamente (DNS, Traefik, Prometheus, OTel)
* GHCR Pull Secret gerenciado por Terraform (código implementado)

Resultado Esperado:

Namespaces protegidos por políticas de rede e preparados para utilização de registries privados.

## Status

✅ Concluída

---

# Sprint 6 - Terraform CI/CD

## Objetivo

Automatizar validações e execuções Terraform.

## Entregas

### Qualidade

* terraform fmt -check
* terraform validate
* tflint

### Segurança

* checkov

### Documentação

* terraform-docs

### Pipeline

* terraform plan
* terraform apply

## Resultado Esperado

Validação automatizada de toda alteração Terraform.

## Status

✅ Concluída

---

# Sprint 7 - GitOps Foundation

## Objetivo

Implementar GitOps como modelo operacional para gerenciamento do cluster e deployments.

## Escopo Previsto

### Argo CD

* Instalação do Argo CD no cluster
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

## Status

📋 Planejada

---

# Sprint 8 - Cloud Foundation (AWS)

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
* EKS (Kubernetes gerenciado)

### Data Layer

* RDS PostgreSQL

### Observability

* Integração cloud-native de observabilidade

## Resultado Esperado

Plataforma completamente reproduzível em infraestrutura AWS.

## Status

📋 Planejada

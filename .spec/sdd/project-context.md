# Challenge DevOps - Project Context

## Visão Geral

O challenge-devops é um projeto de demonstração prática de DevOps, DevSecOps, Kubernetes, Observabilidade e Platform Engineering.

A plataforma utiliza FastAPI, Docker, Kubernetes (Kind), Helm, GitHub Actions, Prometheus, Grafana, Tempo, Trivy, SBOM e Cosign para simular um ambiente corporativo moderno com múltiplos ambientes (DEV, HML e PROD) e promoção imutável de artefatos.

Loki e Promtail estão previstos como evolução futura da stack de observabilidade.

---

## Objetivo da Evolução Terraform

Introduzir Terraform como camada oficial de Infrastructure as Code da plataforma.

A implementação tem como objetivo eliminar dependências operacionais manuais e transformar toda a infraestrutura compartilhada em código reproduzível, auditável e versionado.

Terraform é a única fonte de verdade para a infraestrutura da plataforma.

---

# Arquitetura

## Cluster Kubernetes (Kind)

O cluster Kind já está provisionado e operacional, com 1 control-plane e 2 workers (labels: `platform-app` e `platform-observability`).

Atualmente provisionado via `kind create cluster --config deploy/kind/cluster.yml`.

Evolução futura: gerenciamento via Terraform (terraform/bootstrap/).

## Terraform

Responsável pelo provisionamento e gerenciamento da infraestrutura da plataforma no cluster Kubernetes.

### Escopo Atual

* Namespaces
* ResourceQuotas
* LimitRanges
* NetworkPolicies
* Traefik
* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector
* GHCR Pull Secrets

### Escopo Futuro

* Cluster Kind (via bootstrap)
* Loki
* Promtail

---

## Helm

Responsável exclusivamente pelos recursos da aplicação.

### Escopo

* Deployment
* Service
* ConfigMap
* Secret
* IngressRoute
* HPA (futuro)
* PDB (futuro)

---

## GitHub Actions

Responsável pelos fluxos de integração contínua, segurança, promoção e entrega.

### CI

* Ruff
* Black
* Isort
* Pytest

### Security

* Trivy
* SBOM
* Cosign
* SARIF

### Delivery

* Build
* Push
* Promotion DEV → HML → PROD
* Helm Deploy
* Health Checks

---

# Princípios Arquiteturais

1. Terraform provisiona infraestrutura.
2. Helm entrega aplicações.
3. GitHub Actions orquestra pipelines.
4. Nenhum recurso possui múltiplos responsáveis.
5. Toda infraestrutura deve ser reproduzível por código.
6. Toda alteração deve ser auditável.
7. Infrastructure as Code é a única fonte de verdade.

---

# ADRs

### ADR-001

Terraform será a ferramenta oficial de Infrastructure as Code.

Status: Accepted

### ADR-002

Helm continuará sendo utilizado para deployment de aplicações.

Status: Accepted

### ADR-003

GitHub Actions continuará sendo o orquestrador de CI/CD.

Status: Accepted

### ADR-004

Terraform utilizará módulos reutilizáveis.

Status: Accepted

### ADR-005

Observabilidade será instalada através do Helm Provider do Terraform.

Status: Accepted

### ADR-006

Namespaces serão gerenciados exclusivamente pelo Terraform.

Status: Accepted

### ADR-007

Validação realizada durante Sprint 4:

- terraform state list contém todas as releases Helm da stack.
- terraform plan converge para "No changes".
- Nenhuma release é gerenciada manualmente via Helm.
- Terraform é a única fonte de verdade da stack de observabilidade.

Status: Accepted

---

# Estrutura Terraform

```text
terraform/
├── bootstrap (vazio - aguardando implementação)
├── environments
│   ├── dev
│   ├── hml
│   ├── prod
│   ├── observability
│   ├── traefik
│   └── security
└── modules
    ├── namespace
    ├── governance
    ├── security
    ├── observability
    └── platform

```

Status dos módulos:

namespace      ✅ Implementado
governance     ✅ Implementado
platform       ✅ Implementado
observability  ✅ Implementado
security       ✅ Implementado

---

# Módulo Namespace

Responsável por:

* Namespace
* Labels
* Annotations

Entradas:

* namespace_name
* labels
* annotations

Saídas:

* namespace_name
* namespace_uid

---

# Módulo Governance

Responsável por:

* ResourceQuota
* LimitRange

Entradas:

* namespace
* requests_cpu
* requests_memory
* limits_cpu
* limits_memory
* default_cpu
* default_memory
* max_cpu
* max_memory

Saídas:

* resource_quota_name
* limit_range_name

---

# Módulo Security

Responsável por:

* NetworkPolicies (Default Deny + Allow Rules)
* GHCR Pull Secret

Recursos de NetworkPolicy:

* default-deny-ingress
* default-deny-egress
* allow-dns-egress
* allow-ingress-from-traefik
* allow-ingress-from-prometheus
* allow-egress-to-otel

Entradas:

* namespace
* enable_default_deny_ingress
* enable_default_deny_egress
* enable_allow_dns_egress
* enable_allow_ingress_from_traefik
* enable_allow_ingress_from_prometheus
* enable_allow_egress_to_otel
* enable_ghcr_secret
* ghcr_registry_server
* ghcr_username
* ghcr_password (sensitive)

Saídas:

* namespace
* ghcr_secret_name
* default_deny_ingress_name
* default_deny_egress_name
* allow_dns_egress_name
* allow_traefik_ingress_name
* allow_prometheus_ingress_name
* allow_otel_egress_name

---

# Módulo Platform

Responsável por:

* Traefik
* Configurações compartilhadas da plataforma Kubernetes
* Componentes de acesso e roteamento

---

# Módulo Observability

Responsável por:

* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector

Evolução futura:

* Loki
* Promtail

---

## Terraform Modules

### namespace

Responsável por:

* Namespace
* Labels
* Annotations

### governance

Responsável por:

* ResourceQuota
* LimitRange

### platform

Responsável por:

* Traefik

### observability

Responsável por:

* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector

### security

Implementado na Sprint 5.

Responsável por:

* NetworkPolicies (Default Deny + Allow Rules)
* GHCR Pull Secret

---

# Namespaces da Plataforma

## DEV

Ambiente de desenvolvimento.
- Namespace gerenciado por Terraform ✅
- ResourceQuota + LimitRange ✅
- Default Deny + Allow Rules (DNS, Traefik, Prometheus, OTel) ✅
- GHCR Pull Secret (desabilitado - aguardando credenciais)

## HML

Ambiente de homologação.
- Namespace gerenciado por Terraform ✅
- ResourceQuota + LimitRange ✅
- Default Deny + Allow Rules (DNS, Traefik, Prometheus, OTel) ✅
- GHCR Pull Secret (desabilitado - aguardando credenciais)

## PROD

Ambiente de produção.
- Namespace gerenciado por Terraform ✅
- ResourceQuota + LimitRange ✅
- Default Deny + Allow Rules (DNS, Traefik, Prometheus, OTel) ✅
- GHCR Pull Secret (desabilitado - aguardando credenciais)

## OBSERVABILITY

Responsável por:

* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector
- Namespace gerenciado por Terraform ✅
- ResourceQuota + LimitRange ✅
- Default Deny + Allow Rules (DNS + Traefik apenas) ✅

## TRAEFIK

Responsável por:

* Traefik Ingress Controller
* Routing Layer
- Namespace gerenciado por Terraform ✅
- ResourceQuota + LimitRange ✅
- Default Deny + Allow Rules (DNS apenas) ✅

---

# Responsabilidades

| Recurso                 | Terraform | Helm | GitHub Actions |
| ----------------------- | --------- | ---- | -------------- |
| Namespace               | Sim       | Não  | Não            |
| ResourceQuota           | Sim       | Não  | Não            |
| LimitRange              | Sim       | Não  | Não            |
| NetworkPolicy           | Sim       | Não  | Não            |
| Traefik                 | Sim       | Não  | Não            |
| Prometheus              | Sim       | Não  | Não            |
| Grafana                 | Sim       | Não  | Não            |
| Tempo                   | Sim       | Não  | Não            |
| Opentelemetry Collector | Sim       | Não  | Não            |
| Loki (futuro)           | Sim       | Não  | Não            |
| Promtail (futuro)       | Sim       | Não  | Não            |
| GHCR Secret             | Sim       | Não  | Não            |
| Deployment              | Não       | Sim  | Não            |
| Service                 | Não       | Sim  | Não            |
| ConfigMap               | Não       | Sim  | Não            |
| Secret Aplicação        | Não       | Sim  | Não            |
| IngressRoute            | Não       | Sim  | Não            |
| Build Docker            | Não       | Não  | Sim            |
| Testes                  | Não       | Não  | Sim            |
| Trivy                   | Não       | Não  | Sim            |
| SBOM                    | Não       | Não  | Sim            |
| Cosign                  | Não       | Não  | Sim            |
| Promotion               | Não       | Não  | Sim            |
| Deploy                  | Não       | Não  | Sim            |

---

# Roadmap Terraform

## Sprint 1 - Foundation

* Providers
* Namespaces

Status: Concluída ✅

## Sprint 2 - Governance

* ResourceQuota
* LimitRange

Status: Concluída ✅

## Sprint 3 - Platform

* Traefik
* Helm Provider
* Platform Module
* Traefik Helm Release
* Terraform Import
* State Convergence

Status: Concluída ✅

## Sprint 4 - Observability Foundation

Entregas

* Importação das releases existentes para Terraform State.
* Gerenciamento da stack exclusivamente via Terraform + Helm Provider.
* Convergência completa do estado.
* Implementação do ADR-007.

Componentes

* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector

Resultado:

No changes.
Your infrastructure matches the configuration.

Status: Concluída ✅

## Sprint 4.1 - Observability Hardening

Objetivos atingidos

Aplicação de ResourceQuota.
Aplicação de LimitRange.
Definição de requests/limits para componentes críticos.
Validação de QoS.
Ajuste de quotas baseado em consumo real da stack.

Resultados observados

Componente:                | QoS
Grafana:                   | Burstable
Prometheus:                | Burstable
Tempo:                     | Burstable
OpenTelemetry Collector:   | Burstable

Validação:

* kubectl describe resourcequota -n observability

Lições aprendidas:

* O chart Tempo 1.24.4 exige configuração via tempo.resources.
* ResourceQuota e LimitRange impediram a criação de pods com recursos incompatíveis.
* O processo de hardening revelou necessidades reais de capacidade do namespace.
* O Prometheus Server possui 2 containers no mesmo pod (prometheus-server e prometheus-server-configmap-reload), o que impacta o cálculo total de recursos.

Status: Concluída ✅

---

## Sprint 5 - Security

Objetivo:

Implementar controles básicos de segurança da plataforma Kubernetes utilizando Terraform como única fonte de verdade para recursos de segurança compartilhados.

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
* terraform apply
* terraform plan

Resultado:
No changes.
Your infrastructure matches the configuration.

Status: Concluída ✅

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

Status: Concluída ✅

---

### Sprint 5.3 - Explicit Traffic Allow Rules

Objetivo:

Liberar apenas os fluxos necessários para funcionamento da plataforma.

Entregas:

* DNS Allow Rules (porta 53 UDP → kube-system)
* Traefik → Aplicações (porta 8000 TCP)
* Prometheus → Aplicações (porta 8000 TCP, scraping de métricas)
* Aplicações → OpenTelemetry Collector (portas 4317/4318 TCP)

Configuração por namespace:

| Namespace      | DNS | Traefik | Prometheus | OTel |
|----------------|-----|---------|------------|------|
| dev            | ✅  | ✅      | ✅         | ✅   |
| hml            | ✅  | ✅      | ✅         | ✅   |
| prod           | ✅  | ✅      | ✅         | ✅   |
| observability  | ✅  | ✅      | ❌         | ❌   |
| traefik        | ✅  | ❌      | ❌         | ❌   |

Validações:

* Testes de acesso via Ingress
* Testes de scraping Prometheus
* Testes de envio de telemetry

Resultado Esperado:

Plataforma funcional operando sob modelo Zero Trust.

Status: Concluída ✅

---

### Sprint 5.4 - Registry Authentication

Objetivo:

Permitir consumo seguro de imagens privadas armazenadas no GitHub Container Registry.

Entregas:

* GHCR Pull Secret
* Secret gerenciado pelo Terraform
* Integração com workloads Kubernetes
* Padronização para DEV, HML e PROD

Validações pendentes:

* kubectl get secret -A (após configurar credenciais)
* Deploy utilizando imagem privada
* Pull bem-sucedido a partir do GHCR

Status: ✅ Implementado (aguardando configuração de credenciais GHCR para ativação)

---

### Resultado Final da Sprint 5

Objetivos atingidos:

* Security Module implementado
* NetworkPolicies gerenciadas por Terraform
* Modelo Default Deny aplicado
* Fluxos necessários liberados explicitamente (DNS, Traefik, Prometheus, OTel)
* GHCR Pull Secret gerenciado por Terraform (código implementado)

Status: ✅ Concluída

---

## Sprint 6 - Terraform CI/CD (Terraform Local)

### Entregas

* terraform fmt -check (qualidade)
* terraform validate (qualidade)
* tflint (qualidade)
* checkov (segurança)
* SARIF Upload (segurança)
* terraform-docs (documentação)
* Terraform CI Pipeline (automação)
* terraform plan (execução)
* terraform apply (execução)

### Status

✅ Concluída

---

# Estado Atual da Implementação Terraform

## Sprint 1 - Foundation

* Estrutura Terraform criada
* Provider Kubernetes configurado
* Módulo Namespace criado
* Namespace DEV gerenciado pelo Terraform
* Namespace HML gerenciado pelo Terraform
* Namespace PROD gerenciado pelo Terraform
* Namespace OBSERVABILITY gerenciado pelo Terraform
* Namespace TRAEFIK gerenciado pelo Terraform

Status: Concluída ✅

## Sprint 2 - Governance

* Módulo Governance criado
* ResourceQuota implementado
* LimitRange implementado
* DEV validado
* HML validado
* PROD validado
* OBSERVABILITY validado
* TRAEFIK validado

Validações executadas:

* terraform fmt -recursive
* terraform validate
* terraform plan
* terraform apply
* terraform state list
* kubectl get resourcequota -A
* kubectl get limitrange -A
* kubectl describe resourcequota

## Sprint 3 - Platform

* Helm Provider
* Platform Module
* Traefik Helm Release
* Terraform Import
* State Convergence
* terraform plan sem divergências
* terraform apply validado
* Helm Release importada para Terraform State

Status: Concluída ✅

## Sprint 4 - Observability

Componentes gerenciados pelo Terraform através do Helm Provider:

* Prometheus
* Grafana
* Tempo
* OpenTelemetry Collector

Entregas:

* Módulo Observability criado
* Environment Observability criado
* Releases Helm importadas para o Terraform State
* State Convergence validada
* terraform plan sem divergências
* terraform apply validado
* ADR-007 implementada

Validações executadas:

* terraform fmt -recursive
* terraform validate
* terraform plan
* terraform import
* terraform apply
* terraform state list

Resultado final:

No changes.
Your infrastructure matches the configuration.

Status: Concluída ✅

## Sprint 4.1 - Observability Hardening

Objetivo:

Adequar a stack de observabilidade às políticas
de governança implementadas na Sprint 2.

Escopo:

* Requests CPU
* Requests Memory
* Limits CPU
* Limits Memory

Validação:

* kubectl describe resourcequota -n observability

Resultado Obtido

Validação executada:

kubectl describe resourcequota -n observability

Resultado:

* requests.cpu > 0
* requests.memory > 0
* limits.cpu > 0
* limits.memory > 0

Validação QoS:

* Grafana → Burstable
* Prometheus → Burstable
* Tempo → Burstable
* OpenTelemetry Collector → Burstable

Objetivo da Sprint atingido.

Status: Concluída ✅

---

## Sprint 5 - Security

Objetivo:

Implementar controles básicos de segurança da plataforma Kubernetes utilizando Terraform como única fonte de verdade para recursos de segurança compartilhados.

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
* terraform apply
* terraform plan

Resultado:
No changes.
Your infrastructure matches the configuration.

Status: Concluída ✅

---

### Sprint 5.2 - Network Segmentation

Objetivo:

Implementar isolamento de tráfego entre workloads através de NetworkPolicies.

Entregas:

* Default Deny Ingress
* Default Deny Egress
* Isolamento entre namespaces
* Validação do comportamento de bloqueio

Validações:

* kubectl get networkpolicy -A
* kubectl describe networkpolicy
* Testes de conectividade entre namespaces

Resultado Esperado:

Todo tráfego passa a ser negado por padrão.

Status: Concluída ✅

---

### Sprint 5.3 - Explicit Traffic Allow Rules

Objetivo:

Liberar apenas os fluxos necessários para funcionamento da plataforma.

Entregas:

* DNS Allow Rules
* Traefik → Aplicações
* Prometheus → Aplicações
* Aplicações → OpenTelemetry Collector

Validações:

* Testes de acesso via Ingress
* Testes de scraping Prometheus
* Testes de envio de telemetry

Resultado Esperado:

Plataforma funcional operando sob modelo Zero Trust.

Status: ✅ Concluída

---

### Sprint 5.4 - Registry Authentication

Objetivo:

Permitir consumo seguro de imagens privadas armazenadas no GitHub Container Registry.

Entregas:

* GHCR Pull Secret
* Secret gerenciado pelo Terraform
* Integração com workloads Kubernetes
* Padronização para DEV, HML e PROD

Validações:

* kubectl get secret -A
* Deploy utilizando imagem privada
* Pull bem-sucedido a partir do GHCR

Resultado Esperado:

Namespaces preparados para consumo de imagens privadas.

Status: ✅ Implementado (aguardando credenciais GHCR)

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

Status: ✅ Concluída

---

# Gerenciamento de Releases Helm

Recursos Helm previamente existentes devem ser importados para o Terraform State antes de serem gerenciados pelo Terraform.

Fluxo adotado:

terraform import
↓
terraform plan
↓
terraform apply
↓
terraform plan

Resultado esperado:

No changes.
Your infrastructure matches the configuration.

Esse padrão foi utilizado para todos os componentes gerenciados via Helm Provider (Traefik, Prometheus, Grafana, Tempo, OTel Collector).

# Observações Técnicas

## Módulo Security
- As Allow Rules de Prometheus e OTel Collector estão desabilitadas por padrão (`default = false`)
- Ativadas explicitamente nos namespaces DEV, HML e PROD via environment security
- Namespace observability: apenas DNS e Traefik ingress (não precisa de scraping ou envio ao OTel)
- Namespace traefik: apenas DNS (ingress controller não precisa dos demais fluxos)

## GHCR Pull Secret
- Recurso implementado e desabilitado por padrão (`enable_ghcr_secret = false`)
- Ativação requer configuração de `ghcr_username` e `ghcr_password` via variáveis
- Secret nomeado como `ghcr-pull-secret` em cada namespace

---

# Evolução Futura AWS

A adoção de AWS não faz parte da fase atual.

Objetivo atual:

terraform apply
↓
Provisionar completamente a plataforma local
↓
Deploy da aplicação via Helm

Após a conclusão da fase local:

## AWS Foundation

Terraform provisionará:

* VPC
* Security Groups
* IAM
* EC2
* S3 Backend
* Terraform Remote State
* DynamoDB State Locking

A arquitetura Kubernetes continuará utilizando Kind inicialmente hospedado em EC2, evitando dependência imediata de EKS e reduzindo custos operacionais.

A migração para serviços gerenciados AWS será avaliada após a conclusão da plataforma Terraform local.

# Status Atual

Sprint 1 - Foundation
✅ Concluída

Sprint 2 - Governance
✅ Concluída

Sprint 3 - Platform
✅ Concluída

Sprint 4 - Observability
✅ Concluída

Sprint 4.1 - Observability Hardening
✅ Concluída

Sprint 5 - Security
✅ Concluída

Sprint 6 - Terraform Local CI/CD
✅ Concluída

Sprint 7 - GitOps Foundation
📋 Planejada

Sprint 8 - Cloud Foundation AWS
📋 Planejada

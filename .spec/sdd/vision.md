# Vision

## Context

O projeto challenge-devops possui uma plataforma Kubernetes funcional com CI/CD, DevSecOps, IaC e observabilidade implementados.

## Situação Atual

A plataforma está completamente operacional com:
- Cluster Kind com 3 nodes (1 control-plane, 2 workers)
- 5 namespaces gerenciados via Terraform (dev, hml, prod, observability, traefik)
- Traefik como Ingress Controller
- Stack de observabilidade completa (Prometheus, Grafana, Tempo, OTel Collector)
- NetworkPolicies com modelo Zero Trust (Default Deny)
- GHCR Pull Secret ativo para imagens privadas
- Pipeline CI/CD automatizado (qualidade, segurança, promoção)
- Pipeline Terraform CI/CD (fmt, validate, tflint, checkov)

## Problema Resolvido

A introdução do Terraform como camada oficial de Infrastructure as Code eliminou:
- Dependências operacionais manuais para criação de namespaces
- Configuração manual de ResourceQuota e LimitRange
- Gerenciamento manual do Traefik
- Gerenciamento manual da stack de observabilidade
- Ausência de políticas de rede (Zero Trust)
- Falta de automação de qualidade e segurança em IaC

## Objetivo

Manter Terraform como camada oficial de provisionamento da plataforma, Helm responsável pela aplicação e GitHub Actions pelos processos de integração, validação e promoção.

## Resultado Obtido

A plataforma é completamente reconstruível a partir de código:
- Infraestrutura: Terraform (6 environments, 5 módulos)
- Aplicação: Helm (chart versionado)
- CI/CD: GitHub Actions (CI + CD DEV/HML/PROD + Terraform CI)
- Segurança: Default Deny + Checkov + TFLint + Trivy
- Observabilidade: Prometheus + Grafana + Tempo + OTel

## Próximos Passos

| Sprint | Foco | Status |
|---|---|---|
| Sprint 7 | GitOps Foundation (ArgoCD) | 📋 Planejada |
| Sprint 8 | Cloud Foundation AWS | 📋 Planejada |

## Princípios Mantidos

1. Terraform provisiona infraestrutura.
2. Helm entrega aplicações.
3. GitHub Actions orquestra pipelines.
4. Nenhum recurso possui múltiplos responsáveis.
5. Infrastructure as Code é a única fonte de verdade.
6. Toda alteração deve ser auditável.
7. Segurança é responsabilidade de todas as camadas.
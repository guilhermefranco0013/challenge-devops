# Estratégia CI/CD profissional

## Visão geral

Esta estratégia implementa:
- CI com lint, testes, validação de imports, build Docker e Trivy.
- CD com Helm Upgrade --install para DEV, HML e PROD.
- Rollback automático em falhas de rollout e healthcheck.
- Integração com GHCR e GitHub Environments para aprovação manual em PROD.

## Estrutura recomendada

.github/workflows/
- ci.yml
- cd-dev.yml
- cd-hml.yml
- cd-prod.yml

## Secrets obrigatórios

- GHCR_USERNAME
- GHCR_TOKEN
- KUBE_CONFIG_BASE64

## Variáveis úteis

- REGISTRY=ghcr.io
- IMAGE_NAME=${{ github.repository_owner }}/challenge-devops
- IMAGE_TAG=${{ github.sha }}

## Etapas da pipeline

1. CI
   - Ruff, Black, Isort
   - Pytest com fail fast
   - validação de import
   - build Docker
   - Trivy (HIGH/CRITICAL) e SBOM
2. CD DEV
   - push na branch develop
   - build/push para GHCR
   - helm upgrade --install
   - rollout status + health check + rollback em falha
3. CD HML
   - push na branch main
   - mesmo fluxo com namespace hml
4. CD PROD
   - workflow_dispatch com GitHub Environment approval
5. Observabilidade
   - links para Grafana, Prometheus e Tempo
   - tag da imagem e versão implantada

## Fases de evolução

- Fase 1: CI + Trivy + Helm Deploy
- Fase 2: GHCR
- Fase 3: GitHub Environments DEV/HML/PROD
- Fase 4: Rollback automático
- Fase 5: ArgoCD
- Fase 6: Progressive Delivery (Canary / Blue-Green)

## Melhorias futuras

- integração com ArgoCD e GitOps
- policy-as-code com OPA/Conftest
- rollout canário e análise automática
- alertas Prometheus/Grafana

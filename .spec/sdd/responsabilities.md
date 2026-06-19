# Responsibilities

## Separação de Responsabilidades

A plataforma challenge-devops segue o princípio de **responsabilidade única por ferramenta**:

- **Terraform**: infraestrutura compartilhada da plataforma
- **Helm**: deployment e configuração da aplicação
- **GitHub Actions**: CI/CD, qualidade, segurança

Nenhum recurso pode ser gerenciado simultaneamente por mais de uma ferramenta.

---

## Tabela de Responsabilidades

| Recurso | Terraform | Helm | GitHub Actions |
|---|---|---|---|
| **Cluster Kind** | Futuro (bootstrap) | Não | Não |
| **Node Labels** | Futuro (bootstrap) | Não | Não |
| **Namespace** | ✅ Sim | Não | Não |
| **ResourceQuota** | ✅ Sim | Não | Não |
| **LimitRange** | ✅ Sim | Não | Não |
| **NetworkPolicy** | ✅ Sim | Não | Não |
| **Traefik** | ✅ Sim (Helm Provider) | Não | Não |
| **Prometheus** | ✅ Sim (Helm Provider) | Não | Não |
| **Grafana** | ✅ Sim (Helm Provider) | Não | Não |
| **Tempo** | ✅ Sim (Helm Provider) | Não | Não |
| **OpenTelemetry Collector** | ✅ Sim (Helm Provider) | Não | Não |
| **Loki** (futuro) | ✅ Sim (futuro) | Não | Não |
| **Promtail** (futuro) | ✅ Sim (futuro) | Não | Não |
| **GHCR Pull Secret** | ✅ Sim | Não | Não |
| **Deployment** | Não | ✅ Sim | Não |
| **Service** | Não | ✅ Sim | Não |
| **ConfigMap** | Não | ✅ Sim | Não |
| **Secret Aplicação** | Não | ✅ Sim | Não |
| **IngressRoute** | Não | ✅ Sim | Não |
| **Build Docker** | Não | Não | ✅ Sim |
| **Testes (Pytest)** | Não | Não | ✅ Sim |
| **Ruff / Black / Isort** | Não | Não | ✅ Sim |
| **Trivy** (security scan) | Não | Não | ✅ Sim |
| **SBOM** (CycloneDX) | Não | Não | ✅ Sim |
| **Cosign** (assinatura) | Não | Não | ✅ Sim |
| **Checkov** (IaC security) | Não | Não | ✅ Sim |
| **TFLint** (Terraform lint) | Não | Não | ✅ Sim |
| **terraform fmt / validate** | Não | Não | ✅ Sim |
| **terraform-docs** | Não | Não | ✅ Sim |
| **Promotion** (DEV → HML → PROD) | Não | Não | ✅ Sim |
| **Deploy** (Helm) | Não | Não | ✅ Sim |
| **Health Checks** | Não | Não | ✅ Sim |
| **SARIF Upload** | Não | Não | ✅ Sim |

---

## Workflows do GitHub Actions

| Workflow | Arquivo | Gatilho | Ações |
|---|---|---|---|
| CI Pipeline | `ci.yml` | Push develop / PR main | Ruff, Black, Isort, Pytest, Trivy, SBOM, Cosign, Build, Push |
| CD DEV | `cd-dev.yml` | Após CI | Helm Deploy em dev, Health Check |
| CD HML | `cd-hml.yml` | Promoção manual | Helm Deploy em hml, Health Check |
| CD PROD | `cd-prod.yml` | Promoção manual | Helm Deploy em prod, Health Check |
| Terraform CI | `terraform-ci.yml` | Alterações em terraform/ | fmt, validate, tflint, checkov, docs, plan, apply |

---

## Environments Terraform

| Environment | Responsabilidade | Provider |
|---|---|---|
| `dev/` | Namespace + Governance DEV | kubernetes |
| `hml/` | Namespace + Governance HML | kubernetes |
| `prod/` | Namespace + Governance PROD | kubernetes |
| `traefik/` | Namespace + Governance + Traefik | kubernetes, helm |
| `observability/` | Namespace + Governance + Observabilidade | kubernetes, helm |
| `security/` | NetworkPolicies + GHCR Secret | kubernetes |

---

## Módulos Terraform

| Módulo | Provider | Responsabilidade |
|---|---|---|
| `namespace` | kubernetes | Namespace, Labels, Annotations |
| `governance` | kubernetes | ResourceQuota, LimitRange |
| `platform` | helm | Traefik (Ingress Controller) |
| `observability` | helm | Prometheus, Grafana, Tempo, OTel |
| `security` | kubernetes | NetworkPolicies, GHCR Pull Secret |
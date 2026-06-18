# Terraform Environments

## Objetivo

Representar os ambientes da plataforma challenge-devops.

Cada ambiente possui seu próprio estado Terraform e é responsável pelo provisionamento dos recursos definidos para aquele namespace.

---

## Ambientes

### DEV

Namespace de desenvolvimento.

Responsável por:

- Namespace DEV
- Governance DEV

### HML

Namespace de homologação.

Responsável por:

- Namespace HML
- Governance HML

### PROD

Namespace de produção.

Responsável por:

- Namespace PROD
- Governance PROD

### OBSERVABILITY

Namespace compartilhado de observabilidade.

Responsável por:

- Prometheus
- Grafana
- Tempo
- Loki
- Promtail

### TRAEFIK

Namespace compartilhado de plataforma.

Responsável por:

- Traefik Ingress Controller
- Routing Layer

---

## Execução

Exemplo:

```bash
cd terraform/environments/dev

terraform init
terraform validate
terraform plan
terraform apply
```

---

## Princípios

- Cada ambiente possui estado isolado.
- Terraform é a única fonte de verdade.
- Infraestrutura é reproduzível por código.
- Nenhuma alteração manual é permitida.
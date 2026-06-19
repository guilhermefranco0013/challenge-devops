# Terraform Module: namespace

## Objetivo

Provisionar e gerenciar namespaces Kubernetes no cluster Kind.

Este módulo é o bloco fundamental da plataforma — todo recurso no cluster depende de um namespace gerenciado por este módulo.

---

## Recursos Gerenciados

| Recurso | Tipo | Descrição |
|---|---|---|
| `kubernetes_namespace.this` | `kubernetes_namespace` | Criação do namespace |
| `metadata.labels` | map(string) | Labels para identificação |
| `metadata.annotations` | map(string) | Annotations para metadados |

---

## Entradas (Inputs)

| Nome | Tipo | Default | Obrigatório | Descrição |
|---|---|---|---|---|
| `namespace_name` | `string` | — | ✅ | Nome do namespace (ex: `dev`, `prod`) |
| `labels` | `map(string)` | — | ✅ | Labels aplicadas ao namespace |
| `annotations` | `map(string)` | `{}` | ❌ | Annotations aplicadas ao namespace |

---

## Saídas (Outputs)

| Nome | Descrição |
|---|---|
| `namespace_name` | Nome do namespace criado |
| `namespace_uid` | UID do namespace criado |

---

## Sprint de Implementação

| Sprint | Descrição | Status |
|---|---|---|
| **Sprint 1 - Foundation** | Criação do módulo, providers, namespaces gerenciados | ✅ Concluída |

---

## Exemplo de Uso

```hcl
module "dev_namespace" {
  source = "../../modules/namespace"

  namespace_name = "dev"

  labels = {
    environment = "dev"
    managed-by  = "terraform"
  }
}
```

---

## Uso na Plataforma

Este módulo é utilizado pelos seguintes environments:

| Environment | Namespace | Labels |
|---|---|---|
| `dev` | `dev` | `environment=dev`, `managed-by=terraform` |
| `hml` | `hml` | `environment=hml`, `managed-by=terraform` |
| `prod` | `prod` | `environment=prod`, `managed-by=terraform` |
| `observability` | `observability` | `environment=observability`, `managed-by=terraform` |
| `traefik` | `traefik` | `environment=traefik`, `managed-by=terraform` |

---

## Validações no Pipeline CI/CD

Este módulo é validado pelo pipeline `terraform-ci.yml`:

| Etapa | Ferramenta | Comando |
|---|---|---|
| Formatação | `terraform fmt -check` | `terraform fmt -check terraform/modules/namespace/` |
| Validação | `terraform validate` | `terraform validate terraform/modules/namespace/` |
| Lint | `tflint` | `tflint --config=terraform/.tflint.hcl terraform/modules/namespace/` |
| Segurança IaC | `checkov` | `checkov -d terraform/modules/namespace/` |

---

## Responsabilidade

**Este módulo é responsável exclusivamente por:**
- Criar namespaces
- Aplicar labels
- Aplicar annotations

**Não é responsabilidade deste módulo:**
- ResourceQuota (módulo `governance`)
- LimitRange (módulo `governance`)
- NetworkPolicy (módulo `security`)
- Deployments (Helm)
- Services (Helm)

---

## Providers

| Provider | Versão |
|---|---|
| `hashicorp/kubernetes` | `~> 2.32` |

---

## ADRs Relacionadas

- **ADR-001**: Terraform como ferramenta oficial de IaC
- **ADR-004**: Módulos reutilizáveis
- **ADR-006**: Namespaces gerenciados exclusivamente pelo Terraform

---

## Roadmap Futuro

| Sprint | Descrição | Status |
|---|---|---|
| **Sprint 7 - GitOps Foundation** | ArgoCD, Application of Applications, Sync Policies | 📋 Planejada |
| **Sprint 8 - Cloud Foundation AWS** | S3 Backend, DynamoDB Locking, VPC, EKS | 📋 Planejada |
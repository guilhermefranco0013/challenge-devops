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
# Namespace Module

## Objetivo

Provisionar namespaces Kubernetes através do Terraform.

Este módulo é utilizado para criar e gerenciar namespaces da plataforma challenge-devops.

---

## Recursos Gerenciados

- Kubernetes Namespace
- Labels
- Annotations

---

## Entradas

| Nome | Tipo | Descrição |
|--------|--------|--------|
| namespace_name | string | Nome do namespace |
| labels | map(string) | Labels aplicadas ao namespace |
| annotations | map(string) | Annotations aplicadas ao namespace |

---

## Saídas

| Nome | Descrição |
|--------|--------|
| namespace_name | Nome do namespace criado |
| namespace_uid | UID do namespace criado |

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

## Responsabilidade

Este módulo é responsável exclusivamente pela criação e gerenciamento de namespaces Kubernetes.

Não é responsabilidade deste módulo:

- ResourceQuota
- LimitRange
- NetworkPolicy
- Deployments
- Services
- Observability
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.32 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.32 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Namespace annotations | `map(string)` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Namespace labels | `map(string)` | n/a | yes |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | The name of the Kubernetes namespace to create. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | The name of the created Kubernetes namespace. |
| <a name="output_namespace_uid"></a> [namespace\_uid](#output\_namespace\_uid) | The UID of the created Kubernetes namespace. |
<!-- END_TF_DOCS -->
# Governance Module

Responsável por implementar governança básica dos namespaces Kubernetes.

Recursos:

- ResourceQuota
- LimitRange

## Inputs

| Nome | Tipo |
|--------|--------|
| namespace | string |
| requests_cpu | string |
| requests_memory | string |
| limits_cpu | string |
| limits_memory | string |
| default_cpu | string |
| default_memory | string |
| max_cpu | string |
| max_memory | string |

## Outputs

| Nome |
|--------|
| resource_quota_name |
| limit_range_name |
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
| [kubernetes_limit_range.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/limit_range) | resource |
| [kubernetes_resource_quota.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_default_cpu"></a> [default\_cpu](#input\_default\_cpu) | The default amount of CPU for the governance resources. | `string` | n/a | yes |
| <a name="input_default_memory"></a> [default\_memory](#input\_default\_memory) | The default amount of memory for the governance resources. | `string` | n/a | yes |
| <a name="input_limits_cpu"></a> [limits\_cpu](#input\_limits\_cpu) | The amount of CPU limited for the governance resources. | `string` | n/a | yes |
| <a name="input_limits_memory"></a> [limits\_memory](#input\_limits\_memory) | The amount of memory limited for the governance resources. | `string` | n/a | yes |
| <a name="input_max_cpu"></a> [max\_cpu](#input\_max\_cpu) | The maximum amount of CPU for the governance resources. | `string` | n/a | yes |
| <a name="input_max_memory"></a> [max\_memory](#input\_max\_memory) | The maximum amount of memory for the governance resources. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace where the governance resources will be created. | `string` | n/a | yes |
| <a name="input_requests_cpu"></a> [requests\_cpu](#input\_requests\_cpu) | The amount of CPU requested for the governance resources. | `string` | n/a | yes |
| <a name="input_requests_memory"></a> [requests\_memory](#input\_requests\_memory) | The amount of memory requested for the governance resources. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_limit_range_name"></a> [limit\_range\_name](#output\_limit\_range\_name) | LimitRange name |
| <a name="output_resource_quota_name"></a> [resource\_quota\_name](#output\_resource\_quota\_name) | ResourceQuota name |
<!-- END_TF_DOCS -->
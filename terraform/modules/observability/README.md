# Observability Module

## Purpose

Provisionar e gerenciar a stack de observabilidade da plataforma através do Terraform utilizando o Helm Provider.

## Managed Components

- Prometheus
- Grafana
- Tempo
- OpenTelemetry Collector

## Future Components

- Loki
- Promtail

## Dependencies

- Namespace Module
- Governance Module

## Ownership

Terraform

## Related ADRs

- ADR-001
- ADR-005
- ADR-007

## Migration Strategy

As releases existentes devem seguir o fluxo:

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
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.14 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.14 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.grafana](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.otel_collector](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.tempo](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_grafana_values_file"></a> [grafana\_values\_file](#input\_grafana\_values\_file) | Arquivo values do grafana. | `string` | n/a | yes |
| <a name="input_grafana_version"></a> [grafana\_version](#input\_grafana\_version) | Versão do chart Grafana. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace da stack de observabilidade. | `string` | n/a | yes |
| <a name="input_otel_collector_values_file"></a> [otel\_collector\_values\_file](#input\_otel\_collector\_values\_file) | Arquivo values do OpenTelemetry Collector. | `string` | n/a | yes |
| <a name="input_otel_collector_version"></a> [otel\_collector\_version](#input\_otel\_collector\_version) | Versão do chart OpenTelemetry Collector. | `string` | n/a | yes |
| <a name="input_prometheus_values_file"></a> [prometheus\_values\_file](#input\_prometheus\_values\_file) | Arquivo values do prometheus. | `string` | n/a | yes |
| <a name="input_prometheus_version"></a> [prometheus\_version](#input\_prometheus\_version) | Versão do chart Prometheus. | `string` | n/a | yes |
| <a name="input_tempo_values_file"></a> [tempo\_values\_file](#input\_tempo\_values\_file) | Arquivo values do tempo. | `string` | n/a | yes |
| <a name="input_tempo_version"></a> [tempo\_version](#input\_tempo\_version) | Versão do chart Tempo. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_grafana_release"></a> [grafana\_release](#output\_grafana\_release) | Nome da release Helm do Grafana. |
| <a name="output_otel_collector_release"></a> [otel\_collector\_release](#output\_otel\_collector\_release) | Nome da release Helm do OpenTelemetry Collector. |
| <a name="output_prometheus_release"></a> [prometheus\_release](#output\_prometheus\_release) | Nome da release Helm do Prometheus. |
| <a name="output_tempo_release"></a> [tempo\_release](#output\_tempo\_release) | Nome da release Helm do Tempo. |
<!-- END_TF_DOCS -->
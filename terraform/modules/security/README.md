# Security Module

## Objetivo

Implementar controles básicos de segurança da plataforma Kubernetes utilizando Terraform como única fonte de verdade para recursos de segurança compartilhados.

## Recursos Gerenciados

### NetworkPolicies (Sprint 5.2 - 5.3)

- **Default Deny Ingress** - Bloqueia todo tráfego de entrada por padrão.
- **Default Deny Egress** - Bloqueia todo tráfego de saída por padrão.
- **Allow DNS Egress** - Permite resolução de DNS (porta 53 UDP para kube-system).
- **Allow Ingress from Traefik** - Permite tráfego HTTP do Traefik (porta 8000 TCP).
- **Allow Ingress from Prometheus** - Permite scraping de métricas pelo Prometheus (porta 8000 TCP).
- **Allow Egress to OpenTelemetry Collector** - Permite envio de telemetria (portas 4317/4318 TCP).

### GHCR Pull Secret (Sprint 5.4)

- **ghcr-pull-secret** - Secret do tipo docker-registry para autenticação no GitHub Container Registry.

## Entradas

|                   Nome               | Tipo   |   Default   |             Descrição                    |
|--------------------------------------|--------|-------------|------------------------------------------|
|              namespace               | string |      -      |            Namespace alvo                |
| enable_default_deny_ingress          |  bool  |     true    | Habilita política Default Deny Ingress   |
| enable_default_deny_egress           |  bool  |     true    | Habilita política Default Deny Egress    |
| enable_allow_dns_egress              |  bool  |     true    | Habilita regra DNS Egress                |
| enable_allow_ingress_from_traefik    |  bool  |     true    | Habilita regra Ingress do Traefik        |
| enable_allow_ingress_from_prometheus |  bool  |     false   | Habilita regra Ingress do Prometheus     |
| enable_allow_egress_to_otel          |  bool  |     false   | Habilita regra Egress para OTel Collector|
| enable_ghcr_secret                   |  bool  |     false   | Habilita criação do GHCR Pull Secret     |
| ghcr_registry_server                 | string |  "ghcr.io"  | URL do registry GHCR                     |
| ghcr_username                        | string |     ""      | Usuário GHCR                             |
| ghcr_password                        | string |     ""      | Token GHCR (sensitive)                   |

## Saídas

| Nome | Descrição |
|------|-----------|
| namespace | Namespace gerenciado |
| ghcr_secret_name | Nome do GHCR Pull Secret (se criado) |
| default_deny_ingress_name | Nome da política Default Deny Ingress |
| default_deny_egress_name | Nome da política Default Deny Egress |
| allow_dns_egress_name | Nome da política Allow DNS Egress |
| allow_traefik_ingress_name | Nome da política Allow Ingress do Traefik |
| allow_prometheus_ingress_name | Nome da política Allow Ingress do Prometheus |
| allow_otel_egress_name | Nome da política Allow Egress para OTel |

## Roadmap

### Sprint 5.1 - Estrutura inicial do módulo ✅
### Sprint 5.2 - Default Deny NetworkPolicies ✅
### Sprint 5.3 - Allow Rules ✅
### Sprint 5.4 - GHCR Pull Secret ✅

## Dependências

- Namespace Module (pré-existente)

## Ownership

Terraform
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
| [kubernetes_network_policy_v1.allow_dns_egress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy_v1) | resource |
| [kubernetes_network_policy_v1.allow_egress_to_otel](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy_v1) | resource |
| [kubernetes_network_policy_v1.allow_ingress_from_prometheus](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy_v1) | resource |
| [kubernetes_network_policy_v1.allow_ingress_from_traefik](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy_v1) | resource |
| [kubernetes_network_policy_v1.default_deny_egress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy_v1) | resource |
| [kubernetes_network_policy_v1.default_deny_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy_v1) | resource |
| [kubernetes_secret_v1.ghcr_pull_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enable_allow_dns_egress"></a> [enable\_allow\_dns\_egress](#input\_enable\_allow\_dns\_egress) | Enable allow DNS egress rule (port 53 UDP to kube-system). | `bool` | `true` | no |
| <a name="input_enable_allow_egress_to_otel"></a> [enable\_allow\_egress\_to\_otel](#input\_enable\_allow\_egress\_to\_otel) | Enable allow egress to OpenTelemetry Collector (namespace observability, ports 4317/4318 TCP). | `bool` | `false` | no |
| <a name="input_enable_allow_ingress_from_prometheus"></a> [enable\_allow\_ingress\_from\_prometheus](#input\_enable\_allow\_ingress\_from\_prometheus) | Enable allow ingress from Prometheus (namespace observability, port 8000 TCP). | `bool` | `false` | no |
| <a name="input_enable_allow_ingress_from_traefik"></a> [enable\_allow\_ingress\_from\_traefik](#input\_enable\_allow\_ingress\_from\_traefik) | Enable allow ingress from Traefik (namespace traefik, port 8000 TCP). | `bool` | `true` | no |
| <a name="input_enable_default_deny_egress"></a> [enable\_default\_deny\_egress](#input\_enable\_default\_deny\_egress) | Enable default deny egress policy. | `bool` | `true` | no |
| <a name="input_enable_default_deny_ingress"></a> [enable\_default\_deny\_ingress](#input\_enable\_default\_deny\_ingress) | Enable default deny ingress policy. | `bool` | `true` | no |
| <a name="input_enable_ghcr_secret"></a> [enable\_ghcr\_secret](#input\_enable\_ghcr\_secret) | Enable GHCR pull secret creation. | `bool` | `false` | no |
| <a name="input_ghcr_password"></a> [ghcr\_password](#input\_ghcr\_password) | GHCR token or password for authentication. | `string` | `""` | no |
| <a name="input_ghcr_registry_server"></a> [ghcr\_registry\_server](#input\_ghcr\_registry\_server) | GHCR registry server URL. | `string` | `"ghcr.io"` | no |
| <a name="input_ghcr_username"></a> [ghcr\_username](#input\_ghcr\_username) | GHCR username for authentication. | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Target namespace where security resources will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_allow_dns_egress_name"></a> [allow\_dns\_egress\_name](#output\_allow\_dns\_egress\_name) | Name of the allow DNS egress network policy. |
| <a name="output_allow_otel_egress_name"></a> [allow\_otel\_egress\_name](#output\_allow\_otel\_egress\_name) | Name of the allow egress to OpenTelemetry Collector network policy. |
| <a name="output_allow_prometheus_ingress_name"></a> [allow\_prometheus\_ingress\_name](#output\_allow\_prometheus\_ingress\_name) | Name of the allow ingress from Prometheus network policy. |
| <a name="output_allow_traefik_ingress_name"></a> [allow\_traefik\_ingress\_name](#output\_allow\_traefik\_ingress\_name) | Name of the allow ingress from Traefik network policy. |
| <a name="output_default_deny_egress_name"></a> [default\_deny\_egress\_name](#output\_default\_deny\_egress\_name) | Name of the default deny egress network policy. |
| <a name="output_default_deny_ingress_name"></a> [default\_deny\_ingress\_name](#output\_default\_deny\_ingress\_name) | Name of the default deny ingress network policy. |
| <a name="output_ghcr_secret_name"></a> [ghcr\_secret\_name](#output\_ghcr\_secret\_name) | Name of the GHCR pull secret, if created. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace managed by the security module. |
<!-- END_TF_DOCS -->
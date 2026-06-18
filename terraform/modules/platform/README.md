# Platform Module

## Objetivo

Provisionar e gerenciar componentes compartilhados da plataforma Kubernetes através do Terraform.

Atualmente o módulo é responsável pelo gerenciamento do Traefik Ingress Controller utilizando o Helm Provider.

---

## Recursos Gerenciados

### Traefik

Responsável por:

* Ingress Controller
* Routing Layer
* Exposição dos serviços da plataforma
* Roteamento HTTP
* Roteamento HTTPS

---

## Arquitetura

```text
Terraform
│
├── Helm Provider
│
└── Helm Release
    └── Traefik
```

---

## Recursos Provisionados

### Helm Release

Recurso Terraform:

```hcl
helm_release.traefik
```

Chart:

```text
traefik
```

Repository:

```text
https://traefik.github.io/charts
```

---

## Entradas

| Variável              | Tipo   | Descrição                          |
| --------------------- | ------ | ---------------------------------- |
| namespace             | string | Namespace de instalação            |
| traefik_chart_version | string | Versão do Chart Helm               |
| replicas              | number | Quantidade de réplicas             |
| web_node_port         | number | NodePort HTTP                      |
| websecure_node_port   | number | NodePort HTTPS                     |
| node_selector_role    | string | Label utilizada para Node Selector |

---

## Saídas

| Output          | Descrição                   |
| --------------- | --------------------------- |
| traefik_release | Nome da release Helm criada |

---

## Configuração Atual

A release atualmente utiliza:

```yaml
deployment:
  replicas: 1

nodeSelector:
  role: platform-observability

service:
  type: LoadBalancer

ports:
  web:
    nodePort: 30080

  websecure:
    nodePort: 30443
```

---

## Fluxo de Gerenciamento

### Novas Instalações

```text
Terraform
↓
Helm Provider
↓
Helm Release
↓
Traefik
```

### Recursos Existentes

```text
Declarar recurso
↓
terraform import
↓
terraform plan
↓
terraform apply
↓
terraform plan
↓
No Changes
```

---

## Responsabilidades

O módulo Platform é responsável exclusivamente por componentes compartilhados da plataforma Kubernetes.

Atualmente:

* Traefik Ingress Controller
* Routing Layer

Não é responsabilidade deste módulo:

* Deployments da aplicação
* Services da aplicação
* ConfigMaps da aplicação
* Secrets da aplicação
* Observabilidade
* Segurança
* Governança

---

## Estado Atual

Sprint 3 - Platform

Status:

✅ Concluída

Validações executadas:

```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform state list

helm history traefik -n traefik
helm get values traefik -n traefik
```

Resultado:

```text
Terraform State
=
Helm Release
=
Cluster Kubernetes
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.32 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.17.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.traefik](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where Traefik will be installed. | `string` | n/a | yes |
| <a name="input_node_selector_role"></a> [node\_selector\_role](#input\_node\_selector\_role) | Node Selector role | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of traefik replicas. | `number` | n/a | yes |
| <a name="input_traefik_chart_version"></a> [traefik\_chart\_version](#input\_traefik\_chart\_version) | Traefik Helm charts version. | `string` | n/a | yes |
| <a name="input_web_node_port"></a> [web\_node\_port](#input\_web\_node\_port) | NodePort for HTTP traffic. | `number` | n/a | yes |
| <a name="input_websecure_node_port"></a> [websecure\_node\_port](#input\_websecure\_node\_port) | NodePort for HTTPS traffic. | `number` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_traefik_release"></a> [traefik\_release](#output\_traefik\_release) | The Traefik helm release name. |
<!-- END_TF_DOCS -->
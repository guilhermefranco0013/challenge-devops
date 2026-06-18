# Terraform Module: platform

## Objetivo

Provisionar e gerenciar componentes compartilhados da plataforma Kubernetes através do Terraform.

Atualmente, este módulo é responsável pelo **Traefik Ingress Controller**, utilizando o Helm Provider para gerenciar a release Helm.

---

## Arquitetura

```text
Terraform
│
├── Helm Provider
│
└── helm_release.traefik
        └── Chart: traefik (https://traefik.github.io/charts)
                └── Traefik Ingress Controller
```

---

## Recursos Gerenciados

| Recurso | Tipo | Descrição |
|---|---|---|
| `helm_release.traefik` | `helm_release` | Release Helm do Traefik |

### Traefik

- Ingress Controller
- Routing Layer
- Exposição dos serviços da plataforma
- Roteamento HTTP (NodePort 30080)
- Roteamento HTTPS (NodePort 30443)

---

## Entradas (Inputs)

| Nome | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `namespace` | `string` | ✅ | Namespace de instalação |
| `traefik_chart_version` | `string` | ✅ | Versão do chart Helm do Traefik |
| `replicas` | `number` | ✅ | Quantidade de réplicas |
| `web_node_port` | `number` | ✅ | NodePort para tráfego HTTP |
| `websecure_node_port` | `number` | ✅ | NodePort para tráfego HTTPS |
| `node_selector_role` | `string` | ✅ | Label para node selector |

---

## Saídas (Outputs)

| Nome | Descrição |
|---|---|
| `traefik_release` | Nome da release Helm do Traefik |

---

## Exemplo de Uso

```hcl
module "traefik_platform" {
  source = "../../modules/platform"

  namespace = "traefik"

  traefik_chart_version = "40.2.0"

  replicas = 1

  web_node_port       = 30080
  websecure_node_port = 30443

  node_selector_role = "platform-observability"
}
```

---

## Configuração Atual (Kind)

| Parâmetro | Valor | Descrição |
|---|---|---|
| Chart version | `40.2.0` | Versão do chart traefik |
| Réplicas | `1` | Single pod (ambiente local) |
| Service type | `LoadBalancer` | Exposto via port mappings do Kind |
| web.nodePort | `30080` | Porta HTTP |
| websecure.nodePort | `30443` | Porta HTTPS |
| nodeSelector.role | `platform-observability` | Executa em node de observabilidade |

---

## Responsabilidade

**Este módulo é responsável por:**
- Traefik Ingress Controller
- Routing Layer
- Exposição dos serviços da plataforma

**Não é responsabilidade deste módulo:**
- Deployments da aplicação (Helm)
- Services da aplicação (Helm)
- ConfigMaps da aplicação (Helm)
- Secrets da aplicação (Helm)
- Observabilidade (módulo `observability`)
- Segurança (módulo `security`)
- Governança (módulo `governance`)
- IngressRoutes da aplicação (Helm)

---

## Providers

| Provider | Versão |
|---|---|
| `hashicorp/helm` | `~> 2.14` |
| `hashicorp/kubernetes` | `~> 2.32` |

> Nota: O provider `kubernetes` está declarado em `versions.tf` mas não é utilizado diretamente neste módulo. Apenas o provider `helm` é necessário para o recurso `helm_release`.

---

## Fluxo de Gerenciamento

### Nova instalação

```bash
terraform init
terraform plan
terraform apply
```

### Importação de release existente

```bash
terraform import helm_release.traefik traefik/traefik
terraform plan
terraform apply
terraform plan  # Deve retornar "No changes"
```

---

## ADRs Relacionadas

- **ADR-001**: Terraform como ferramenta oficial de IaC
- **ADR-003**: GitHub Actions como orquestrador de CI/CD
- **ADR-005**: Observabilidade instalada via Helm Provider do Terraform
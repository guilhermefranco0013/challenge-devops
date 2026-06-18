# Terraform Module: security

## Objetivo

Implementar controles de segurança da plataforma Kubernetes utilizando Terraform como única fonte de verdade para recursos de segurança compartilhados.

---

## Arquitetura de Segurança

```text
Terraform
│
├── Kubernetes Provider
│
├── NetworkPolicies (Sprint 5.2 - 5.3)
│   ├── default-deny-ingress
│   ├── default-deny-egress
│   ├── allow-dns-egress
│   ├── allow-ingress-from-traefik
│   ├── allow-ingress-from-prometheus
│   └── allow-egress-to-otel
│
└── GHCR Pull Secret (Sprint 5.4)
    └── ghcr-pull-secret (docker-registry)
```

---

## Recursos Gerenciados

### NetworkPolicies

| Recurso | Descrição | Porta | Destino/Origem |
|---|---|---|---|
| `default-deny-ingress` | Bloqueia todo tráfego de entrada | — | — |
| `default-deny-egress` | Bloqueia todo tráfego de saída | — | — |
| `allow-dns-egress` | Permite resolução de DNS | 53/UDP | `kube-system` |
| `allow-ingress-from-traefik` | Permite tráfego HTTP do Traefik | 8000/TCP | Namespace `traefik` |
| `allow-ingress-from-prometheus` | Permite scraping de métricas | 8000/TCP | Namespace `observability` (pod prometheus) |
| `allow-egress-to-otel` | Permite envio de telemetria | 4317, 4318/TCP | Namespace `observability` (pod otel-collector) |

### GHCR Pull Secret

| Recurso | Tipo | Descrição |
|---|---|---|
| `ghcr-pull-secret` | `kubernetes.io/dockerconfigjson` | Autenticação no GitHub Container Registry |

---

## Modelo de Segurança: Zero Trust

A plataforma opera sob modelo **Default Deny**:

```text
Todo tráfego é negado por padrão
         │
         ▼
Liberado apenas o necessário:
  ├── DNS → kube-system (porta 53 UDP)
  ├── Traefik → apps (porta 8000 TCP)
  ├── Prometheus → apps (porta 8000 TCP)
  └── apps → OTel Collector (portas 4317/4318 TCP)
```

---

## Entradas (Inputs)

| Nome | Tipo | Default | Obrigatório | Descrição |
|---|---|---|---|---|
| `namespace` | `string` | — | ✅ | Namespace alvo |
| `enable_default_deny_ingress` | `bool` | `true` | ❌ | Habilita Default Deny Ingress |
| `enable_default_deny_egress` | `bool` | `true` | ❌ | Habilita Default Deny Egress |
| `enable_allow_dns_egress` | `bool` | `true` | ❌ | Habilita regra DNS Egress |
| `enable_allow_ingress_from_traefik` | `bool` | `true` | ❌ | Habilita regra Ingress do Traefik |
| `enable_allow_ingress_from_prometheus` | `bool` | `false` | ❌ | Habilita regra Ingress do Prometheus |
| `enable_allow_egress_to_otel` | `bool` | `false` | ❌ | Habilita regra Egress para OTel |
| `enable_ghcr_secret` | `bool` | `false` | ❌ | Habilita GHCR Pull Secret |
| `ghcr_registry_server` | `string` | `"ghcr.io"` | ❌ | URL do registry GHCR |
| `ghcr_username` | `string` | `""` | ❌ | Usuário GHCR |
| `ghcr_password` | `string` (sensitive) | `""` | ❌ | Token GHCR |

---

## Saídas (Outputs)

| Nome | Descrição |
|---|---|
| `namespace` | Namespace gerenciado |
| `ghcr_secret_name` | Nome do GHCR Pull Secret (se criado) |
| `default_deny_ingress_name` | Nome da política Default Deny Ingress |
| `default_deny_egress_name` | Nome da política Default Deny Egress |
| `allow_dns_egress_name` | Nome da política Allow DNS Egress |
| `allow_traefik_ingress_name` | Nome da política Allow Ingress do Traefik |
| `allow_prometheus_ingress_name` | Nome da política Allow Ingress do Prometheus |
| `allow_otel_egress_name` | Nome da política Allow Egress para OTel |

---

## Configuração por Namespace

| Namespace | Default Deny | DNS | Traefik | Prometheus | OTel | GHCR |
|---|---|---|---|---|---|---|
| `dev` | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| `hml` | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| `prod` | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| `observability` | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| `traefik` | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |

> **Nota**: Namespace `observability` não precisa de scraping Prometheus (ele mesmo) nem envio ao OTel. Namespace `traefik` só precisa de DNS.

---

## Exemplo de Uso

```hcl
# Namespace dev com todas as permissões
module "dev_security" {
  source = "../../modules/security"

  namespace = "dev"

  enable_default_deny_ingress = true
  enable_default_deny_egress  = true

  enable_allow_dns_egress              = true
  enable_allow_ingress_from_traefik    = true
  enable_allow_ingress_from_prometheus = true
  enable_allow_egress_to_otel          = true

  enable_ghcr_secret = false
}
```

---

## Dependências

Este módulo depende de:

1. **Namespace alvo existente** — criado pelo módulo `namespace`
2. **Traefik** — necessário para a regra `allow-ingress-from-traefik`
3. **Prometheus** — necessário para a regra `allow-ingress-from-prometheus`
4. **OpenTelemetry Collector** — necessário para a regra `allow-egress-to-otel`

> **Importante**: O environment `security` deve ser executado **após** todos os outros environments (dev, hml, prod, traefik, observability) para garantir que os namespaces alvo existam.

---

## GHCR Pull Secret

O secret `ghcr-pull-secret` está **implementado porém desabilitado por padrão** (`enable_ghcr_secret = false`).

Para ativar:

```hcl
module "dev_security" {
  source = "../../modules/security"

  namespace = "dev"

  enable_ghcr_secret = true
  ghcr_username      = var.ghcr_username  # ou valor direto
  ghcr_password      = var.ghcr_password  # sensitive
}
```

---

## Providers

| Provider | Versão |
|---|---|
| `hashicorp/kubernetes` | `~> 2.32` |

---

## Lições Aprendidas

Durante a implementação inicial, foi identificado um **namespace hardcoded** (`"dev"`) no módulo security, o que provocava tentativas de criação do mesmo recurso em múltiplos módulos.

**Correção aplicada:**
```hcl
# Antes (incorreto)
namespace = "dev"

# Depois (correto)
namespace = var.namespace
```

---

## ADRs Relacionadas

- **ADR-001**: Terraform como ferramenta oficial de IaC
- **ADR-004**: Módulos reutilizáveis
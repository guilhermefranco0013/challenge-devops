# Terraform Module: governance

## Objetivo

Implementar políticas de governança básica para namespaces Kubernetes, garantindo controle de recursos e limites de consumo por container.

---

## Recursos Gerenciados

| Recurso | Tipo | Descrição |
|---|---|---|
| `kubernetes_resource_quota.this` | `kubernetes_resource_quota` | Limita o consumo agregado de recursos do namespace (CPU, memória, pods) |
| `kubernetes_limit_range.this` | `kubernetes_limit_range` | Define limites padrão e máximos para containers individuais |

---

## Como Funciona

### ResourceQuota

Controla o consumo **agregado** de todos os pods dentro do namespace:

- `requests.cpu` — Total de CPU reservada
- `requests.memory` — Total de memória reservada
- `limits.cpu` — Limite máximo de CPU
- `limits.memory` — Limite máximo de memória
- `pods` — Quantidade máxima de pods (fixo em 20)

### LimitRange

Controla o consumo **individual** de cada container:

- `default` — Valores aplicados quando o container não define `resources`
- `max` — Valores máximos permitidos por container

---

## Entradas (Inputs)

| Nome | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `namespace` | `string` | ✅ | Namespace alvo |
| `requests_cpu` | `string` | ✅ | CPU total reservada (ex: `"250m"`) |
| `requests_memory` | `string` | ✅ | Memória total reservada (ex: `"256Mi"`) |
| `limits_cpu` | `string` | ✅ | Limite máximo de CPU (ex: `"500m"`) |
| `limits_memory` | `string` | ✅ | Limite máximo de memória (ex: `"512Mi"`) |
| `default_cpu` | `string` | ✅ | CPU padrão por container (ex: `"100m"`) |
| `default_memory` | `string` | ✅ | Memória padrão por container (ex: `"128Mi"`) |
| `max_cpu` | `string` | ✅ | CPU máxima por container (ex: `"500m"`) |
| `max_memory` | `string` | ✅ | Memória máxima por container (ex: `"512Mi"`) |

---

## Saídas (Outputs)

| Nome | Descrição |
|---|---|
| `resource_quota_name` | Nome do ResourceQuota criado |
| `limit_range_name` | Nome do LimitRange criado |

---

## Exemplo de Uso

```hcl
module "dev_governance" {
  source = "../../modules/governance"

  namespace = "dev"

  requests_cpu    = "250m"
  requests_memory = "256Mi"

  limits_cpu    = "500m"
  limits_memory = "512Mi"

  default_cpu    = "100m"
  default_memory = "128Mi"

  max_cpu    = "500m"
  max_memory = "512Mi"
}
```

---

## Uso na Plataforma

| Environment | requests.cpu | requests.memory | limits.cpu | limits.memory | default.cpu | default.memory | max.cpu | max.memory |
|---|---|---|---|---|---|---|---|---|
| `dev` | 250m | 256Mi | 500m | 512Mi | 100m | 128Mi | 500m | 512Mi |
| `hml` | 1000m | 1024Mi | 2000m | 2048Mi | 500m | 512Mi | 2000m | 2048Mi |
| `prod` | 3000m | 3072Mi | 4000m | 4096Mi | 2000m | 2048Mi | 4000m | 4096Mi |
| `observability` | 2 | 2Gi | 4 | 6Gi | 500m | 512Mi | 2 | 2Gi |
| `traefik` | 250m | 256Mi | 500m | 512Mi | 100m | 128Mi | 500m | 512Mi |

---

## Boas Práticas

1. **ResourceQuota + LimitRange sempre juntos**: ResourceQuota sozinho não impede que um único container consuma todos os recursos. LimitRange sozinho não impede consumo agregado excessivo.
2. **Valores realistas**: Baseie os valores em métricas reais de consumo (kubectl top pods, Prometheus) para evitar overprovisioning.
3. **QoS Classes**: A combinação de `requests` e `limits` define a classe de QoS do pod:
   - `requests == limits` → **Guaranteed**
   - `requests < limits` → **Burstable**
   - sem requests/limits → **BestEffort**

---

## Providers

| Provider | Versão |
|---|---|
| `hashicorp/kubernetes` | `~> 2.32` |

---

## ADRs Relacionadas

- **ADR-001**: Terraform como ferramenta oficial de IaC
- **ADR-004**: Módulos reutilizáveis
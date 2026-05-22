# Deployment

## Visão geral

O projeto `challenge-devops` suporta múltiplas estratégias de implantação e execução local, permitindo validação tanto em ambientes de desenvolvimento quanto em ambientes Kubernetes.

Os modos principais de execução são:

1. Execução local com Python/FastAPI;
2. Execução local containerizada com Docker;
3. Ambiente observável com Docker Compose;
4. Orquestração Kubernetes;
5. Gerenciamento declarativo com Helm.

O `Makefile` centraliza os principais fluxos operacionais do projeto e abstrai comandos repetitivos de desenvolvimento e implantação.

---

# Estrutura de deployment

Os recursos de deployment estão organizados em:

```text
deploy/
  compose/
  docker/
  kubernetes/
  helm/challenge-devops/
```

---

# Comandos operacionais

| Área | Objetivo | Makefile | Comando manual equivalente |
|---|---|---|---|
| 🐳 Docker | Construir imagem Docker | `make docker-build` | `docker build -t challenge-devops -f deploy/docker/Dockerfile .` |
| 🐳 Docker | Executar container Docker | `make docker-run` | `docker run --rm -p 8000:8000 challenge-devops` |
| 🐳 Docker Compose | Subir ambiente | `make compose-up` | `docker compose -f deploy/compose/docker-compose.yml up --build -d` |
| 🐳 Docker Compose | Visualizar logs | `make compose-logs` | `docker compose -f deploy/compose/docker-compose.yml logs --follow` |
| 🐳 Docker Compose | Parar ambiente | `make compose-down` | `docker compose -f deploy/compose/docker-compose.yml down` |
| ☸️ Kubernetes | Aplicar manifests | `make kube-apply` | `kubectl apply -f deploy/kubernetes` |
| ☸️ Kubernetes | Remover manifests | `make kube-delete` | `kubectl delete -f deploy/kubernetes --ignore-not-found` |
| ☸️ Kubernetes | Visualizar recursos | `make kube-status` | `kubectl get all -n challenge-devops` |
| ☸️ Kubernetes | Fazer port-forward | `make port-forward` | `kubectl port-forward svc/challenge-devops-service 8082:80 -n challenge-devops` |
| ☸️ Kubernetes | Visualizar logs | `make kube-logs` | `kubectl logs -f deployment/challenge-devops -n challenge-devops` |
| 📦 Helm | Validar chart | `make helm-lint` | `helm lint deploy/helm/challenge-devops` |
| 📦 Helm | Renderizar templates | `make helm-template` | `helm template challenge-devops deploy/helm/challenge-devops --namespace challenge-devops` |
| 📦 Helm | Instalar release | `make helm-install` | `helm install challenge-devops deploy/helm/challenge-devops --namespace challenge-devops --create-namespace` |
| 📦 Helm | Atualizar release | `make helm-upgrade` | `helm upgrade challenge-devops deploy/helm/challenge-devops --namespace challenge-devops --reuse-values` |
| 📦 Helm | Remover release | `make helm-uninstall` | `helm uninstall challenge-devops --namespace challenge-devops` |

---

# Docker

## Visão geral

A aplicação é containerizada utilizando Docker com estratégia multi-stage build para otimização da imagem final.

O Dockerfile está localizado em:

```text
deploy/docker/Dockerfile
```

---

## Estrutura do build

O build utiliza duas etapas principais:

| Stage | Objetivo |
|---|---|
| `builder` | Instalar dependências Python |
| `runtime` | Executar aplicação com imagem enxuta |

---

## Características do container

- aplicação FastAPI executada via Uvicorn;
- porta `8000` exposta;
- `HEALTHCHECK` validando `/health`;
- otimização de dependências;
- separação entre build e runtime.

---

## Build da imagem

### Via Makefile

```bash
make docker-build
```

---

### Comando manual equivalente

```bash
docker build -t challenge-devops -f deploy/docker/Dockerfile .
```

---

## Execução local do container

### Via Makefile

```bash
make docker-run
```

---

### Comando manual equivalente

```bash
docker run --rm -p 8000:8000 challenge-devops
```

---

## Validação da aplicação

```bash
curl localhost:8000
```

Resposta esperada:

```json
{"status":"ok"}
```

---

# Docker Compose

## Visão geral

O ambiente Docker Compose permite executar localmente:

- aplicação FastAPI;
- Prometheus;
- Grafana.

O arquivo principal está localizado em:

```text
deploy/compose/docker-compose.yml
```

---

## Recursos implementados

- build automático da aplicação;
- observabilidade integrada;
- healthcheck da API;
- mapeamento de portas;
- suporte a `.env`.

---

## Serviços disponíveis

| Serviço | Porta |
|---|---|
| FastAPI | `8000` |
| Prometheus | `9090` |
| Grafana | `3000` |

---

## Subir ambiente

### Via Makefile

```bash
make compose-up
```

---

### Comando manual equivalente

```bash
docker compose -f deploy/compose/docker-compose.yml up --build -d
```

---

## Visualizar logs

### Via Makefile

```bash
make compose-logs
```

---

### Comando manual equivalente

```bash
docker compose -f deploy/compose/docker-compose.yml logs --follow
```

---

## Parar ambiente

### Via Makefile

```bash
make compose-down
```

---

### Comando manual equivalente

```bash
docker compose -f deploy/compose/docker-compose.yml down
```

---

# Kubernetes

## Visão geral

A aplicação pode ser implantada em Kubernetes utilizando manifests YAML ou Helm Charts.

Os manifests estão localizados em:

```text
deploy/kubernetes/
```

---

## Recursos Kubernetes implementados

| Recurso | Arquivo |
|---|---|
| Namespace | `namespace.yaml` |
| Deployment | `deployment.yaml` |
| Service | `service.yaml` |
| Ingress | `ingress.yaml` |

---

## Deployment

O deployment Kubernetes implementa:

- replicas configuráveis;
- readinessProbe;
- livenessProbe;
- exposição da porta `8000`;
- variáveis de ambiente;
- integração com Service.

---

## Healthchecks Kubernetes

As probes utilizam:

```text
/health
```

para validação operacional da aplicação.

---

## Service Kubernetes

O Service expõe:

```text
porta 80 -> container 8000
```

permitindo acesso interno dentro do cluster.

---

## Observações importantes

### imagePullPolicy

Atualmente:

```yaml
imagePullPolicy: Never
```

Esse valor é adequado para:
- clusters locais;
- Kind;
- Minikube;
- ambientes de laboratório.

Para produção recomenda-se:

```yaml
imagePullPolicy: IfNotPresent
```

ou:

```yaml
imagePullPolicy: Always
```

---

# Aplicar manifests Kubernetes

### Via Makefile

```bash
make kube-apply
```

---

### Comando manual equivalente

```bash
kubectl apply -f deploy/kubernetes
```

---

# Remover manifests Kubernetes

### Via Makefile

```bash
make kube-delete
```

---

### Comando manual equivalente

```bash
kubectl delete -f deploy/kubernetes --ignore-not-found
```

---

# Visualizar recursos Kubernetes

### Via Makefile

```bash
make kube-status
```

---

### Comando manual equivalente

```bash
kubectl get all -n challenge-devops
```

---

# Port-forward Kubernetes

O port-forward expõe localmente o Service Kubernetes.

---

## Via Makefile

```bash
make port-forward
```

---

## Comando manual equivalente

```bash
kubectl port-forward svc/challenge-devops-service 8082:80 -n challenge-devops
```

---

## Fluxo operacional

```text
localhost:8082
        ↓
Kubernetes Service :80
        ↓
Pod :8000
        ↓
FastAPI
```

---

## Endpoints disponíveis

| Endpoint | URL |
|---|---|
| Root | `http://localhost:8082/` |
| Healthcheck | `http://localhost:8082/health` |
| Metrics | `http://localhost:8082/metrics` |

---

# Logs Kubernetes

## Via Makefile

```bash
make kube-logs
```

---

## Comando manual equivalente

```bash
kubectl logs -f deployment/challenge-devops -n challenge-devops
```

---

# Helm

## Visão geral

O projeto utiliza Helm para gerenciamento declarativo da aplicação Kubernetes.

O chart está localizado em:

```text
deploy/helm/challenge-devops
```

---

# Estrutura do chart

| Arquivo | Objetivo |
|---|---|
| `Chart.yaml` | Metadados do chart |
| `values.yaml` | Valores parametrizáveis |
| `templates/deployment.yaml` | Deployment Kubernetes |
| `templates/service.yaml` | Service Kubernetes |

---

# Recursos Helm implementados

- parametrização de imagem;
- replicas configuráveis;
- namespace configurável;
- service configurável;
- portas configuráveis.

---

# Exemplo de configuração

```yaml
replicaCount: 2

image:
  repository: challenge-devops
  pullPolicy: IfNotPresent

service:
  type: NodePort
  port: 80
```

---

# Validar chart Helm

### Via Makefile

```bash
make helm-lint
```

---

### Comando manual equivalente

```bash
helm lint deploy/helm/challenge-devops
```

---

# Renderizar templates Helm

### Via Makefile

```bash
make helm-template
```

---

### Comando manual equivalente

```bash
helm template challenge-devops \
  deploy/helm/challenge-devops \
  --namespace challenge-devops
```

---

# Instalar release Helm

### Via Makefile

```bash
make helm-install
```

---

### Comando manual equivalente

```bash
helm install challenge-devops \
  deploy/helm/challenge-devops \
  --namespace challenge-devops \
  --create-namespace
```

---

# Atualizar release Helm

### Via Makefile

```bash
make helm-upgrade
```

---

### Comando manual equivalente

```bash
helm upgrade challenge-devops \
  deploy/helm/challenge-devops \
  --namespace challenge-devops \
  --reuse-values
```

---

# Remover release Helm

### Via Makefile

```bash
make helm-uninstall
```

---

### Comando manual equivalente

```bash
helm uninstall challenge-devops --namespace challenge-devops
```

---

# Qualidade do deployment

A estratégia de deployment atual demonstra:

- containerização moderna;
- observabilidade integrada;
- automação operacional;
- integração Kubernetes;
- gerenciamento Helm;
- práticas cloud-native;
- organização modular da infraestrutura.

---

# Melhorias futuras recomendadas

Adicionar:

- Ingress Controller;
- HPA;
- RBAC;
- Secrets Management;
- Network Policies;
- Resource Limits;
- GitOps;
- Deploy automatizado via CI/CD.
# Deployment

## Visão geral

A implantação do projeto suporta três modos principais:

1. Docker local
2. Docker Compose local
3. Kubernetes e Helm

O `Makefile` centraliza os comandos de execução e implantação na raiz do repositório.

## Comandos Makefile recomendados

- `make docker-build`
- `make docker-run`
- `make compose-up`
- `make compose-down`
- `make compose-logs`
- `make k8s-apply`
- `make k8s-port-forward`
- `make helm-install`
- `make helm-upgrade`

## Docker Image

A imagem está definida em `deploy/docker/Dockerfile` com multi-stage build.

- Stage `builder`: instala dependências em `/root/.local`
- Stage `runtime`: copia o código e configura o ambiente
- O container expõe a porta `8000`
- `HEALTHCHECK` valida o endpoint `/health`

## Docker Compose

O ambiente local de desenvolvimento usa `deploy/compose/docker-compose.yml`.

- Serviço `app` construído a partir de `deploy/docker/Dockerfile`
- Mapeamento de porta `8000:8000`
- Healthcheck para `/health`
- Leitura de variáveis via `../../.env`

## Kubernetes

Os manifests estão em `deploy/kubernetes/`:

- `namespace.yaml`
- `deployment.yaml`
- `service.yaml`
- `ingress.yaml`

### Observações importantes

- `deployment.yaml` usa readiness e liveness probes para `/health`
- `service.yaml` expõe o app internamente na porta `80`
- `imagePullPolicy: Never` é útil para cluster local, mas não é recomendado em produção

### Aplicar manifests

```bash
make k8s-apply
```

### Port forward

```bash
make k8s-port-forward
```

Isso expõe `svc/challenge-devops-service:80` localmente em `http://127.0.0.1:8082`.

## Helm

O chart está em `deploy/helm/challenge-devops`.

### Instalação

```bash
make helm-install
```

### Atualização

```bash
make helm-upgrade
```

### Arquivos chave

- `Chart.yaml`
- `values.yaml`
- `templates/deployment.yaml`
- `templates/service.yaml`

## Qualidade do deploy

A documentação agora inclui os principais comandos de developer experience e os valores padrão do Helm.

### Exemplo de snippet de deploy

```yaml
# deploy/helm/challenge-devops/values.yaml
replicaCount: 2
image:
  repository: challenge-devops
  pullPolicy: IfNotPresent

service:
  type: NodePort
  port: 80
```

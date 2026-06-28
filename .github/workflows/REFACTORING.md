# Refatoração das Pipelines CI/CD

## Problemas Encontrados

### 1. Gerenciador de Pacotes Python
- **Problema**: Uso de `pip` e `venv` tradicional
- **Impacto**: Incompatibilidade com a padronização do projeto que adotou `uv`
- **Severidade**: Alta

### 2. Ativação de Virtual Environment
- **Problema**: Uso de `.venv/bin/activate` (Linux) ao invés de `.venv\Scripts\activate` (Windows)
- **Impacto**: Falha na ativação do ambiente virtual no Windows
- **Severidade**: Crítica

### 3. Comandos Shell Incompatíveis
- **Problema**: Uso de `for i in $(seq 1 30)` e `sleep 5` (bash)
- **Impacto**: Falha na execução de health checks no Windows
- **Severidade**: Crítica

### 4. Caminhos de Arquivo
- **Problema**: Uso de `/tmp/pf.log` e `/dev/null`
- **Impacto**: Caminhos inexistentes no Windows
- **Severidade**: Crítica

### 5. Runners Linux
- **Problema**: Jobs `lint` e `security` do terraform-ci.yml usando `runs-on: [self-hosted, Linux, ...]`
- **Impacto**: Falha se runner Linux não estiver disponível
- **Severidade**: Alta

### 6. Cache Legado
- **Problema**: Uso de `cache: pip` no setup-python
- **Impacto**: Cache não otimizado para uv
- **Severidade**: Média

### 7. Makefile Incompatível
- **Problema**: Uso de `find` (Linux) e caminhos `/bin`
- **Impacto**: Falha na execução de comandos make no Windows
- **Severidade**: Alta

## Justificativa Técnica das Alterações

### Migração para UV

**Motivo**: O projeto padronizou o uso de `uv` como gerenciador oficial de Python.

**Benefícios**:
- Performance 10-100x mais rápido que pip
- Cache mais eficiente
- Resolução de dependências mais confiável
- Compatibilidade com `pyproject.toml`
- Alinhamento com ambiente local e CI

**Implementação**:
```yaml
# Antes
- uses: actions/setup-python@v5
  with:
    python-version: "3.12"
    cache: pip

# Depois
- uses: astral-sh/setup-uv@v4
  with:
    python-version: "3.12"
```

### Compatibilidade Windows

**Motivo**: Migração de WSL2 para Windows Host.

**Alterações**:
1. Virtual environment: `.venv\Scripts\activate` (Windows) ao invés de `.venv/bin/activate` (Linux)
2. Health check: PowerShell loop ao invés de bash `seq`
3. Sleep: `Start-Sleep -Seconds 5` ao invés de `sleep 5`
4. Paths: `$env:TEMP\pf.log` ao invés de `/tmp/pf.log`
5. Null device: `$null` ao invés de `/dev/null`

### Cache Strategy

**Motivo**: Otimizar tempo de pipeline evitando downloads desnecessários.

**Implementação**:
- `uv sync` com cache nativo do uv
- Remoção de cache legado do pip
- Cache de dependências Python entre execuções

### Shell Padronização

**Motivo**: Evitar mistura de shells e garantir compatibilidade.

**Decisão**: Usar PowerShell como shell padrão no Windows.

**Justificativa**:
- Runner é Windows nativo
- PowerShell é shell padrão do Windows
- Não há necessidade de bash/WSL
- Melhor performance e compatibilidade

## Melhorias Aplicadas

### Performance
- ✅ Cache nativo do uv (mais rápido que pip)
- ✅ Remoção de etapas redundantes
- ✅ Eliminação de `python -m venv` (uv sync gerencia ambiente)
- ✅ Uso de `uv run` para execução isolada

### Manutenibilidade
- ✅ Eliminação de ativação manual de venv
- ✅ Comandos mais simples e diretos
- ✅ Menos pontos de falha
- ✅ Código mais limpo

### Compatibilidade
- ✅ 100% Windows-native
- ✅ Sem dependência de WSL2
- ✅ Sem comandos bash
- ✅ Sem caminhos Unix

### Segurança
- ✅ Mantida verificação de assinatura de imagem
- ✅ Mantidos scans de vulnerabilidade (Trivy, Checkov)
- ✅ Mantido upload de SARIF para GitHub Security

## Arquivos Modificados

1. `.github/workflows/ci.yml` - Pipeline principal de CI
2. `.github/workflows/cd-dev.yml` - Deploy DEV
3. `.github/workflows/cd-hml.yml` - Deploy HML
4. `.github/workflows/cd-prod.yml` - Deploy PROD
5. `.github/workflows/terraform-ci.yml` - Pipeline Terraform
6. `Makefile` - Comandos locais

## Garantias

### Ambiente Local = CI
- ✅ Mesmo gerenciador de pacotes (uv)
- ✅ Mesma versão Python (3.12)
- ✅ Mesmas ferramentas (ruff, black, isort, pytest)
- ✅ Mesmo comportamento

### Compatibilidade Windows
- ✅ Sem comandos bash
- ✅ Sem caminhos Unix
- ✅ PowerShell nativo
- ✅ Testado em Windows Host

### Performance
- ✅ Cache otimizado
- ✅ Downloads reduzidos
- ✅ Execução mais rápida
- ✅ Menos etapas redundantes

## Próximos Passos Recomendados

1. **PyPI Mirror**: Considerar mirror local para acelerar downloads
2. **Docker Layer Cache**: Revisar estratégia de cache Docker
3. **Parallel Jobs**: Avaliar paralelização de jobs independentes
4. **Matrix Strategy**: Considerar matrix para testes multi-versão
5. **Monitoring**: Adicionar métricas de tempo por etapa
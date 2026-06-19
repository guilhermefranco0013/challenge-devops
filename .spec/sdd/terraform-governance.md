# Terraform Governance

## Objetivo

Estabelecer padrões de qualidade, segurança, documentação e governança para todos os artefatos Terraform utilizados no projeto challenge-devops.

Todos os módulos, ambientes e pipelines Terraform deverão seguir obrigatoriamente as diretrizes definidas neste documento.

---

# Qualidade de Código

Toda alteração Terraform deverá passar pelas seguintes validações:

```bash
terraform fmt -recursive
terraform validate
tflint
```

Objetivos:
* Padronização do código
* Consistência sintática
* Redução de erros de configuração
* Aderência às boas práticas do Terraform

**Configuração atual:** `terraform/.tflint.hcl`

| Regra | Descrição |
|---|---|
| `terraform_documented_outputs` | Outputs devem ter descrição |
| `terraform_documented_variables` | Variáveis devem ter descrição |
| `terraform_typed_variables` | Variáveis devem ter tipo definido |
| `terraform_naming_convention` | snake_case obrigatório |
| `terraform_required_version` | required_version deve existir |
| `terraform_required_providers` | required_providers deve existir |
| `terraform_standard_module_structure` | Estrutura de módulo padronizada |

Nenhum Pull Request deverá ser aprovado com erros críticos reportados pelo TFLint.

---

# Análise Estática

O TFLint será utilizado para:
* Detectar configurações incorretas
* Identificar recursos obsoletos
* Validar providers
* Detectar inconsistências de código

---

# Segurança

A ferramenta oficial de análise de segurança será o Checkov.

```bash
checkov -d terraform/
```

**Configuração atual:** `terraform/.checkov.yml`

| Configuração | Valor |
|---|---|
| skip-check | CKV_K8S_12, 21-25, 30-33, 35-40 (não aplicáveis ao Kind) |
| quiet | true |
| compact | true |
| skip-framework | dockerfile, helm, kubernetes |

Objetivos:
* Detectar configurações inseguras
* Identificar violações de boas práticas
* Validar conformidade da infraestrutura
* Reduzir riscos operacionais

Toda alteração deverá passar pelas verificações de segurança antes de ser promovida para ambientes superiores.

**Pipeline:** `.github/workflows/terraform-ci.yml` — checkov + SARIF Upload.

---

# Documentação

Todos os módulos Terraform deverão possuir documentação gerada automaticamente.

Ferramenta padrão:

```bash
terraform-docs
```

A documentação deverá incluir:
* Descrição do módulo
* Variáveis de entrada
* Outputs
* Providers
* Dependências

A documentação deverá permanecer sincronizada com o código-fonte.

---

# Estrutura de Módulos

Cada módulo deverá seguir o padrão:

```text
terraform/modules/<module-name>/
```

Arquivos obrigatórios:
* `main.tf` — recursos do módulo
* `variables.tf` — variáveis de entrada
* `outputs.tf` — saídas do módulo
* `versions.tf` — versões do Terraform e providers
* `README.md` — documentação completa

Nenhum módulo deverá ser criado sem documentação.

---

# Estrutura de Environments

Cada environment segue o padrão:

```text
terraform/environments/<environment-name>/
```

Arquivos esperados:
* `main.tf` — invocação dos módulos
* `providers.tf` — configuração de providers e versões
* `variables.tf` — variáveis específicas do environment (opcional)
* `terraform.tfvars` — valores das variáveis (quando aplicável)

---

# Pull Requests

Toda alteração Terraform deverá ser realizada através de Pull Request.

O Pull Request deverá conter:
* Objetivo da alteração
* Impacto esperado
* Resultado do `terraform plan`
* Evidências das validações executadas

---

# Pipeline Terraform

O pipeline Terraform CI/CD (`terraform-ci.yml`) executa obrigatoriamente:

```text
terraform fmt -check
    ↓
terraform validate
    ↓
tflint
    ↓
checkov + SARIF
    ↓
terraform-docs
    ↓
terraform plan
    ↓
terraform apply
```

Somente alterações aprovadas em todas as etapas poderão seguir para homologação ou produção.

---

# GHCR Authentication

Variáveis injetadas no pipeline:
- `TF_VAR_ghcr_username`
- `TF_VAR_ghcr_password`

Em execução local, valores lidos de `terraform/environments/security/terraform.tfvars`.

---

# Princípios

1. Infrastructure as Code é a única fonte de verdade.
2. Toda alteração deve ser auditável.
3. Toda alteração deve ser reproduzível.
4. Segurança é responsabilidade de todas as etapas.
5. Documentação deve evoluir junto ao código.
6. Nenhuma infraestrutura crítica deve ser criada manualmente.
7. Checkov e TFLint são barreiras obrigatórias no pipeline.
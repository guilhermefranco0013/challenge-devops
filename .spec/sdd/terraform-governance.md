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

---

# Análise Estática

O TFLint será utilizado para:

* Detectar configurações incorretas
* Identificar recursos obsoletos
* Validar providers
* Detectar inconsistências de código

Nenhum Pull Request deverá ser aprovado com erros críticos reportados pelo TFLint.

---

# Segurança

A ferramenta oficial de análise de segurança será o Checkov.

Validações obrigatórias:

```bash
checkov -d terraform/
```

Objetivos:

* Detectar configurações inseguras
* Identificar violações de boas práticas
* Validar conformidade da infraestrutura
* Reduzir riscos operacionais

Toda alteração deverá passar pelas verificações de segurança antes de ser promovida para ambientes superiores.

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

terraform/modules/<module-name>/

Arquivos obrigatórios:

* main.tf
* variables.tf
* outputs.tf
* versions.tf
* README.md

Nenhum módulo deverá ser criado sem documentação.

---

# Pull Requests

Toda alteração Terraform deverá ser realizada através de Pull Request.

O Pull Request deverá conter:

* Objetivo da alteração
* Impacto esperado
* Resultado do terraform plan
* Evidências das validações executadas

---

# GitHub CLI

O GitHub CLI poderá ser utilizado para:

* Gerenciamento de Pull Requests
* Consulta de Issues
* Integração com pipelines
* Automação operacional

---

# Pipeline Terraform

Toda pipeline Terraform deverá executar obrigatoriamente:

terraform fmt -check
terraform validate
tflint
checkov
terraform-docs

Somente alterações aprovadas em todas as etapas poderão seguir para homologação ou produção.

---

# Princípios

1. Infrastructure as Code é a única fonte de verdade.
2. Toda alteração deve ser auditável.
3. Toda alteração deve ser reproduzível.
4. Segurança é responsabilidade de todas as etapas.
5. Documentação deve evoluir junto ao código.
6. Nenhuma infraestrutura crítica deve ser criada manualmente.

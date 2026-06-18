# TFLint configuration for challenge-devops
#
# Sprint 6 - Terraform CI/CD
# Linter específico para código Terraform.
# Garante qualidade, consistência e boas práticas.
#
# Uso:
#   tflint --config=terraform/.tflint.hcl terraform/modules/namespace/
#   tflint --config=terraform/.tflint.hcl terraform/environments/dev/

config {
  format = "default"
  call_module_type = "all"
  force  = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = false
}

rule "terraform_naming_convention" {
  enabled = true
  format = "snake_case"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}
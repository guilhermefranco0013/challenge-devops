# ------------------------------------------------------------------------------
# Sprint 6 - Terraform CI/CD
# Variáveis de ambiente para o environment security.
#
# GHCR: utilizado para autenticação no GitHub Container Registry.
# AWS: placeholder para futura implementação (Sprint 8).
#
# Em CI/CD, os valores são injetados via TF_VAR_* no workflow.
# Ex: TF_VAR_ghcr_username, TF_VAR_ghcr_password
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# GHCR Pull Secret
# ------------------------------------------------------------------------------
variable "ghcr_username" {
  description = "GHCR username for image pull authentication."
  type        = string
  default     = ""
}

variable "ghcr_password" {
  description = "GHCR token or password for image pull authentication."
  type        = string
  sensitive   = true
  default     = ""
}

# ------------------------------------------------------------------------------
# Placeholder for future AWS provider implementation in Sprint 8.
# Currently unused.
# ------------------------------------------------------------------------------
variable "aws_access_key_id" {
  description = "AWS access key ID for cloud infrastructure (future Sprint 8)."
  type        = string
  default     = ""
}

variable "aws_secret_access_key" {
  description = "AWS secret access key for cloud infrastructure (future Sprint 8)."
  type        = string
  sensitive   = true
  default     = ""
}
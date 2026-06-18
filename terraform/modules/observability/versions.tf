# ------------------------------------------------------------------------------
# Terraform Requirements
# ------------------------------------------------------------------------------
#
# Define versões mínimas suportadas para o Terraform e providers
# utilizados pelo módulo.
#
# Objetivos:
#
# - Garantir reprodutibilidade.
# - Evitar incompatibilidades entre ambientes.
# - Controlar upgrades de providers.
#
# ------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.8.0"


  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
  }
}
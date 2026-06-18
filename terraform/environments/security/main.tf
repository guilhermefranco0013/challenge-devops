# ------------------------------------------------------------------------------
# Sprint 6 - Terraform CI/CD
# Environment: security
# Gerencia NetworkPolicies + GHCR Pull Secret para todos os namespaces.
#
# Variáveis GHCR e AWS são injetadas via TF_VAR_* no pipeline CI/CD
# ou via terraform.tfvars para execução local.
#
# GHCR Pull Secret é ativado automaticamente quando credenciais
# são fornecidas (ghcr_username e ghcr_password não vazios).
# ------------------------------------------------------------------------------

locals {
  ghcr_configured = var.ghcr_username != "" && var.ghcr_password != ""
}

# ------------------------------------------------------------------------------
# Security Module - DEV
# ------------------------------------------------------------------------------
# Aplica Default Deny + Allow Rules para o namespace dev.
# GHCR Pull Secret ativado automaticamente se credenciais forem fornecidas.
# ------------------------------------------------------------------------------
module "dev_security" {
  source = "../../modules/security"

  namespace = "dev"

  # Default Deny
  enable_default_deny_ingress = true
  enable_default_deny_egress  = true

  # Allow Rules
  enable_allow_dns_egress              = true
  enable_allow_ingress_from_traefik    = true
  enable_allow_ingress_from_prometheus = true
  enable_allow_egress_to_otel          = true

  # GHCR Pull Secret - ativado via credentials
  enable_ghcr_secret   = local.ghcr_configured
  ghcr_username        = var.ghcr_username
  ghcr_password        = var.ghcr_password
  ghcr_registry_server = "ghcr.io"
}

# ------------------------------------------------------------------------------
# Security Module - HML
# ------------------------------------------------------------------------------
# Aplica Default Deny + Allow Rules para o namespace hml.
# GHCR Pull Secret ativado automaticamente se credenciais forem fornecidas.
# ------------------------------------------------------------------------------
module "hml_security" {
  source = "../../modules/security"

  namespace = "hml"

  # Default Deny
  enable_default_deny_ingress = true
  enable_default_deny_egress  = true

  # Allow Rules
  enable_allow_dns_egress              = true
  enable_allow_ingress_from_traefik    = true
  enable_allow_ingress_from_prometheus = true
  enable_allow_egress_to_otel          = true

  # GHCR Pull Secret - ativado via credentials
  enable_ghcr_secret   = local.ghcr_configured
  ghcr_username        = var.ghcr_username
  ghcr_password        = var.ghcr_password
  ghcr_registry_server = "ghcr.io"
}

# ------------------------------------------------------------------------------
# Security Module - PROD
# ------------------------------------------------------------------------------
# Aplica Default Deny + Allow Rules para o namespace prod.
# GHCR Pull Secret ativado automaticamente se credenciais forem fornecidas.
# ------------------------------------------------------------------------------
module "prod_security" {
  source = "../../modules/security"

  namespace = "prod"

  # Default Deny
  enable_default_deny_ingress = true
  enable_default_deny_egress  = true

  # Allow Rules
  enable_allow_dns_egress              = true
  enable_allow_ingress_from_traefik    = true
  enable_allow_ingress_from_prometheus = true
  enable_allow_egress_to_otel          = true

  # GHCR Pull Secret - ativado via credentials
  enable_ghcr_secret   = local.ghcr_configured
  ghcr_username        = var.ghcr_username
  ghcr_password        = var.ghcr_password
  ghcr_registry_server = "ghcr.io"
}

# ------------------------------------------------------------------------------
# Security Module - OBSERVABILITY
# ------------------------------------------------------------------------------
# Aplica Default Deny + Allow Rules para o namespace observability.
# GHCR não se aplica (namespace de plataforma).
# ------------------------------------------------------------------------------
module "observability_security" {
  source = "../../modules/security"

  namespace = "observability"

  # Default Deny
  enable_default_deny_ingress = true
  enable_default_deny_egress  = true

  # Allow Rules
  enable_allow_dns_egress           = true
  enable_allow_ingress_from_traefik = true

  # Observabilidade não precisa de scraping do Prometheus ou envio ao Otel
  enable_allow_ingress_from_prometheus = false
  enable_allow_egress_to_otel          = false

  # GHCR não se aplica ao namespace observability
  enable_ghcr_secret   = false
  ghcr_username        = var.ghcr_username
  ghcr_password        = var.ghcr_password
  ghcr_registry_server = "ghcr.io"
}

# ------------------------------------------------------------------------------
# Security Module - TRAEFIK
# ------------------------------------------------------------------------------
# Aplica Default Deny + Allow Rules para o namespace traefik.
# GHCR não se aplica (namespace de plataforma).
# ------------------------------------------------------------------------------
module "traefik_security" {
  source = "../../modules/security"

  namespace = "traefik"

  # Default Deny
  enable_default_deny_ingress = true
  enable_default_deny_egress  = true

  # Allow Rules
  enable_allow_dns_egress = true

  # Traefik não precisa dos outros allow rules
  enable_allow_ingress_from_traefik    = false
  enable_allow_ingress_from_prometheus = false
  enable_allow_egress_to_otel          = false

  # GHCR não se aplica ao namespace traefik
  enable_ghcr_secret   = false
  ghcr_username        = var.ghcr_username
  ghcr_password        = var.ghcr_password
  ghcr_registry_server = "ghcr.io"
}
# ------------------------------------------------------------------------------
# Namespace
# ------------------------------------------------------------------------------
variable "namespace" {
  description = "Target namespace where security resources will be created."
  type        = string
}

# ------------------------------------------------------------------------------
# Sprint 5.2 - Default Deny Policies
# ------------------------------------------------------------------------------
variable "enable_default_deny_ingress" {
  description = "Enable default deny ingress policy."
  type        = bool
  default     = true
}

variable "enable_default_deny_egress" {
  description = "Enable default deny egress policy."
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# Sprint 5.3 - Explicit Traffic Allow Rules
# ------------------------------------------------------------------------------
variable "enable_allow_dns_egress" {
  description = "Enable allow DNS egress rule (port 53 UDP to kube-system)."
  type        = bool
  default     = true
}

variable "enable_allow_ingress_from_traefik" {
  description = "Enable allow ingress from Traefik (namespace traefik, port 8000 TCP)."
  type        = bool
  default     = true
}

variable "enable_allow_ingress_from_prometheus" {
  description = "Enable allow ingress from Prometheus (namespace observability, port 8000 TCP)."
  type        = bool
  default     = false
}

variable "enable_allow_egress_to_otel" {
  description = "Enable allow egress to OpenTelemetry Collector (namespace observability, ports 4317/4318 TCP)."
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# Sprint 5.4 - GHCR Pull Secret
# ------------------------------------------------------------------------------
variable "enable_ghcr_secret" {
  description = "Enable GHCR pull secret creation."
  type        = bool
  default     = false
}

variable "ghcr_registry_server" {
  description = "GHCR registry server URL."
  type        = string
  default     = "ghcr.io"
}

variable "ghcr_username" {
  description = "GHCR username for authentication."
  type        = string
  default     = ""
}

variable "ghcr_password" {
  description = "GHCR token or password for authentication."
  type        = string
  sensitive   = true
  default     = ""
}

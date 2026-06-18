output "namespace" {
  description = "Namespace managed by the security module."
  value       = var.namespace
}

output "ghcr_secret_name" {
  description = "Name of the GHCR pull secret, if created."
  value       = var.enable_ghcr_secret ? kubernetes_secret_v1.ghcr_pull_secret[0].metadata[0].name : null
}

output "default_deny_ingress_name" {
  description = "Name of the default deny ingress network policy."
  value       = var.enable_default_deny_ingress ? kubernetes_network_policy_v1.default_deny_ingress[0].metadata[0].name : null
}

output "default_deny_egress_name" {
  description = "Name of the default deny egress network policy."
  value       = var.enable_default_deny_egress ? kubernetes_network_policy_v1.default_deny_egress[0].metadata[0].name : null
}

output "allow_dns_egress_name" {
  description = "Name of the allow DNS egress network policy."
  value       = var.enable_allow_dns_egress ? kubernetes_network_policy_v1.allow_dns_egress[0].metadata[0].name : null
}

output "allow_traefik_ingress_name" {
  description = "Name of the allow ingress from Traefik network policy."
  value       = var.enable_allow_ingress_from_traefik ? kubernetes_network_policy_v1.allow_ingress_from_traefik[0].metadata[0].name : null
}

output "allow_prometheus_ingress_name" {
  description = "Name of the allow ingress from Prometheus network policy."
  value       = var.enable_allow_ingress_from_prometheus ? kubernetes_network_policy_v1.allow_ingress_from_prometheus[0].metadata[0].name : null
}

output "allow_otel_egress_name" {
  description = "Name of the allow egress to OpenTelemetry Collector network policy."
  value       = var.enable_allow_egress_to_otel ? kubernetes_network_policy_v1.allow_egress_to_otel[0].metadata[0].name : null
}

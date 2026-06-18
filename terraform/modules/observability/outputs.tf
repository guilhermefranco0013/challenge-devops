# ------------------------------------------------------------------------------
# Helm Releases
# ------------------------------------------------------------------------------
#
# Outputs utilizados para rastrear releases gerenciadas pelo Terraform.
# ------------------------------------------------------------------------------
output "prometheus_release" {
  description = "Nome da release Helm do Prometheus."
  value       = helm_release.prometheus.name
}

output "grafana_release" {
  description = "Nome da release Helm do Grafana."
  value       = helm_release.grafana.name
}

output "tempo_release" {
  description = "Nome da release Helm do Tempo."
  value       = helm_release.tempo.name
}

output "otel_collector_release" {
  description = "Nome da release Helm do OpenTelemetry Collector."
  value       = helm_release.otel_collector.name
}
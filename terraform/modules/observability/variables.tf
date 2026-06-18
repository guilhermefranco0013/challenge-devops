# ------------------------------------------------------------------------------
# Namespace
# ------------------------------------------------------------------------------
#
# Namespace previamente provisionado pelo módulo Namespace.
#
# Ownership:
# Terraform
# ------------------------------------------------------------------------------
variable "namespace" {
  description = "Namespace da stack de observabilidade."
  type        = string
}

# ------------------------------------------------------------------------------
# Chart Versions
# ------------------------------------------------------------------------------
#
# As versões são declaradas externamente para permitir upgrades
# controlados e auditáveis através do Terraform.
# ------------------------------------------------------------------------------
variable "prometheus_version" {
  description = "Versão do chart Prometheus."
  type        = string
}

variable "grafana_version" {
  description = "Versão do chart Grafana."
  type        = string
}

variable "tempo_version" {
  description = "Versão do chart Tempo."
  type        = string
}

variable "otel_collector_version" {
  description = "Versão do chart OpenTelemetry Collector."
  type        = string
}

# ------------------------------------------------------------------------------
# Values Files
# ------------------------------------------------------------------------------
#
# Os arquivos values permanecem versionados em deploy/observability
# para manter compatibilidade com a instalação atual dos charts.
# ------------------------------------------------------------------------------
variable "prometheus_values_file" {
  description = "Arquivo values do prometheus."
  type        = string
}

variable "grafana_values_file" {
  description = "Arquivo values do grafana."
  type        = string
}

variable "tempo_values_file" {
  description = "Arquivo values do tempo."
  type        = string
}

variable "otel_collector_values_file" {
  description = "Arquivo values do OpenTelemetry Collector."
  type        = string
}
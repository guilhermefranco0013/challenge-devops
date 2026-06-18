variable "namespace" {
  description = "Namespace da stack de observabilidade."
  type        = string
}

variable "prometheus_version" {
  description = "Versão do chart Prometheus."
  type        = string
}

variable "grafana_version" {
  description = "Versão do chart Grafana."
  type        = string
}

variable "tempo_version" {
  description = "Versão do chart do Tempo."
  type        = string
}

variable "otel_collector_version" {
  description = "Versão do chart OpenTelemetry Collector."
  type        = string
}

variable "prometheus_values_file" {
  description = "Arquivo Values do Prometheus."
  type        = string
}

variable "grafana_values_file" {
  description = "Arquivo values do Grafana."
  type        = string
}

variable "tempo_values_file" {
  description = "Arquivo values do Tempo."
  type        = string
}

variable "otel_collector_values_file" {
  description = "Arquivo values do OpenTelemetry Collector."
  type        = string
}

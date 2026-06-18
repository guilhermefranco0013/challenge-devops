# Namespace OBSERVABILITY.
#
# Responsável pela criação e gerenciamento
# do namespace de desenvolvimento.
module "observability_namespace" {
  source = "../../modules/namespace"

  namespace_name = "observability"

  labels = {
    environment = "observability"
    managed-by  = "terraform"
  }
}

# Governance OBSERVABILITY.
#
# Responsável pela aplicação de políticas
# de governança do namespace:
#
# - ResourceQuota
# - LimitRange
#
# Os valores foram definidos considerando
# o consumo atual do ambiente OBSERVABILITY.
module "observability_governance" {
  source = "../../modules/governance"

  namespace = "observability"

  requests_cpu    = "2"
  requests_memory = "2Gi"

  limits_cpu    = "4"
  limits_memory = "6Gi"

  default_cpu    = "500m"
  default_memory = "512Mi"

  max_cpu    = "2"
  max_memory = "2Gi"
}

# Observability Stack.
#
# Responsável pelo gerenciamento da stack
# de observabilidade da plataforma:
#
# - Prometheus
# - Grafana
# - Tempo
# - OpenTelemetry Collector
#
# Ownership:
# Terraform
module "observability" {
  source = "../../modules/observability"

  namespace = var.namespace

  prometheus_version     = var.prometheus_version
  grafana_version        = var.grafana_version
  tempo_version          = var.tempo_version
  otel_collector_version = var.otel_collector_version

  prometheus_values_file     = var.prometheus_values_file
  grafana_values_file        = var.grafana_values_file
  tempo_values_file          = var.tempo_values_file
  otel_collector_values_file = var.otel_collector_values_file

  depends_on = [
    module.observability_namespace,
    module.observability_governance
  ]

}

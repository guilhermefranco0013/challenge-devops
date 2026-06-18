# ------------------------------------------------------------------------------
# Prometheus
# ------------------------------------------------------------------------------
#
# Responsável pela coleta e armazenamento de métricas da plataforma.
#
# A release existente será importada para o Terraform State durante
# a Sprint 4 seguindo a estratégia de convergência adotada no projeto.
#
# ADRs Relacionadas:
# - ADR-001
#
# - ADR-007
# ------------------------------------------------------------------------------
resource "helm_release" "prometheus" {
  name      = "prometheus"
  namespace = var.namespace

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  version = var.prometheus_version

  values = [
    file(var.prometheus_values_file)
  ]


  # O gerenciamento das releases segue a estratégia de import e
  # convergência adotada pela plataforma.
  #
  # wait = false reduz o tempo de execução durante operações
  # locais em ambiente Kind.
  #
  # timeout = 600 fornece margem para upgrades futuros de charts.
  wait    = false
  timeout = 600
}

# ------------------------------------------------------------------------------
# Grafana
# ------------------------------------------------------------------------------
#
# Responsável pela visualização de métricas, logs e traces da plataforma.
#
# A release existente será importada para o Terraform State durante
# a Sprint 4 seguindo a estratégia de convergência adotada no projeto.
# ------------------------------------------------------------------------------

resource "helm_release" "grafana" {
  name      = "grafana"
  namespace = var.namespace

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"

  version = var.grafana_version

  values = [
    file(var.grafana_values_file)
  ]

  wait    = false
  timeout = 600
}

# ------------------------------------------------------------------------------
# Tempo
# ------------------------------------------------------------------------------
#
# Responsável pelo armazenamento e consulta de traces distribuídos.
#
# A release existente será importada para o Terraform State durante
# a Sprint 4 seguindo a estratégia de convergência adotada no projeto.
# ------------------------------------------------------------------------------
resource "helm_release" "tempo" {
  name      = "tempo"
  namespace = var.namespace

  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"

  version = var.tempo_version

  values = [
    file(var.tempo_values_file)
  ]

  wait    = false
  timeout = 600
}

# ------------------------------------------------------------------------------
# OpenTelemetry Collector
# ------------------------------------------------------------------------------
#
# Responsável pela recepção, processamento e exportação de telemetria
# para os componentes da stack de observabilidade.
#
# A release existente será importada para o Terraform State durante
# a Sprint 4 seguindo a estratégia de convergência adotada no projeto.
# ------------------------------------------------------------------------------
resource "helm_release" "otel_collector" {
  name      = "otel-collector"
  namespace = var.namespace

  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"

  version = var.otel_collector_version

  values = [
    file(var.otel_collector_values_file)
  ]

  wait    = false
  timeout = 600
}

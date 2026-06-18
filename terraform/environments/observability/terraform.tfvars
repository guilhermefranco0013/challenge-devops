namespace = "observability"

prometheus_version     = "29.9.0"
grafana_version        = "10.5.15"
tempo_version          = "1.24.4"
otel_collector_version = "0.158.0"

prometheus_values_file     = "../../../deploy/observability/prometheus-values.yaml"
grafana_values_file        = "../../../deploy/observability/grafana-values.yaml"
tempo_values_file          = "../../../deploy/observability/tempo-values.yaml"
otel_collector_values_file = "../../../deploy/observability/otel-values.yaml"
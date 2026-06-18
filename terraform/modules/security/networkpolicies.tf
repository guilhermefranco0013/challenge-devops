# ------------------------------------------------------------------------------
# Sprint 5.2 - Network Segmentation
# ------------------------------------------------------------------------------
#
# Implementa Default Deny Ingress e Egress para isolar workloads
# dentro do namespace. Todo tráfego é negado por padrão, exceto
# os fluxos explicitamente liberados nas regras allow abaixo.
# ------------------------------------------------------------------------------

resource "kubernetes_network_policy_v1" "default_deny_ingress" {
  count = var.enable_default_deny_ingress ? 1 : 0

  metadata {
    name      = "default-deny-ingress"
    namespace = var.namespace
  }

  spec {
    pod_selector {}

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy_v1" "default_deny_egress" {
  count = var.enable_default_deny_egress ? 1 : 0

  metadata {
    name      = "default-deny-egress"
    namespace = var.namespace
  }

  spec {
    pod_selector {}

    policy_types = ["Egress"]
  }
}

# ------------------------------------------------------------------------------
# Sprint 5.3 - Explicit Traffic Allow Rules
# ------------------------------------------------------------------------------
#
# Libera apenas os fluxos necessários para o funcionamento da plataforma:
#
# 1. DNS (porta 53 UDP) - resolução de nomes
# 2. Traefik → Aplicações (ingress)
# 3. Prometheus → Aplicações (scraping de métricas)
# 4. Aplicações → OpenTelemetry Collector (envio de telemetria)
# 5. Observabilidade entre componentes da stack
# ------------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Allow DNS Egress
# ---------------------------------------------------------------------------
# Necessário para que todos os pods resolvam nomes de serviços
# e endpoints externos.
# ---------------------------------------------------------------------------
resource "kubernetes_network_policy_v1" "allow_dns_egress" {
  count = var.enable_allow_dns_egress ? 1 : 0

  metadata {
    name      = "allow-dns-egress"
    namespace = var.namespace
  }

  spec {
    pod_selector {}

    egress {
      ports {
        port     = "53"
        protocol = "UDP"
      }

      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "kube-system"
          }
        }
      }
    }

    policy_types = ["Egress"]
  }
}

# ---------------------------------------------------------------------------
# Allow Ingress from Traefik
# ---------------------------------------------------------------------------
# Permite que o Traefik (namespace traefik) encaminhe tráfego HTTP/HTTPS
# para os pods da aplicação neste namespace.
# ---------------------------------------------------------------------------
resource "kubernetes_network_policy_v1" "allow_ingress_from_traefik" {
  count = var.enable_allow_ingress_from_traefik ? 1 : 0

  metadata {
    name      = "allow-ingress-from-traefik"
    namespace = var.namespace
  }

  spec {
    pod_selector {}

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "traefik"
          }
        }
      }

      ports {
        port     = "8000"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}

# ---------------------------------------------------------------------------
# Allow Ingress from Prometheus
# ---------------------------------------------------------------------------
# Permite que o Prometheus (namespace observability) faça scraping
# de métricas dos pods da aplicação neste namespace.
# Aplica-se a todos os pods do namespace (pod_selector vazio).
# ---------------------------------------------------------------------------
resource "kubernetes_network_policy_v1" "allow_ingress_from_prometheus" {
  count = var.enable_allow_ingress_from_prometheus ? 1 : 0

  metadata {
    name      = "allow-ingress-from-prometheus"
    namespace = var.namespace
  }

  spec {
    pod_selector {}

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "observability"
          }
        }

        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "prometheus"
          }
        }
      }

      ports {
        port     = "8000"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}

# ---------------------------------------------------------------------------
# Allow Egress to OpenTelemetry Collector
# ---------------------------------------------------------------------------
# Permite que os pods da aplicação enviem traces, métricas e logs
# para o OpenTelemetry Collector no namespace observability.
# Aplica-se a todos os pods do namespace (pod_selector vazio).
# ---------------------------------------------------------------------------
resource "kubernetes_network_policy_v1" "allow_egress_to_otel" {
  count = var.enable_allow_egress_to_otel ? 1 : 0

  metadata {
    name      = "allow-egress-to-otel"
    namespace = var.namespace
  }

  spec {
    pod_selector {}

    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "observability"
          }
        }

        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "opentelemetry-collector"
          }
        }
      }

      ports {
        port     = "4317"
        protocol = "TCP"
      }

      ports {
        port     = "4318"
        protocol = "TCP"
      }
    }

    policy_types = ["Egress"]
  }
}

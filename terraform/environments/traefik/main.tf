# Namespace TRAEFIK.
#
# Responsável pela criação e gerenciamento
# do namespace de desenvolvimento.
module "traefik_namespace" {
  source = "../../modules/namespace"

  namespace_name = "traefik"

  labels = {
    environment = "traefik"
    managed-by  = "terraform"
  }
}

# Governance TRAEFIK.
#
# Responsável pela aplicação de políticas
# de governança do namespace:
#
# - ResourceQuota
# - LimitRange
#
# Os valores foram definidos considerando
# o consumo atual do ambiente TRAEFIK.
module "traefik_governance" {
  source = "../../modules/governance"

  namespace = "traefik"

  requests_cpu    = "250m"
  requests_memory = "256Mi"

  limits_cpu    = "500m"
  limits_memory = "512Mi"

  default_cpu    = "100m"
  default_memory = "128Mi"

  max_cpu    = "500m"
  max_memory = "512Mi"
}

# Platform Module.
#
# Responsável pelo provisionamento
# do Traefik através do Helm Provider.
module "traefik_platform" {

  source = "../../modules/platform"

  namespace = "traefik"

  traefik_chart_version = "40.2.0"

  replicas = 1

  web_node_port       = 30080
  websecure_node_port = 30443

  node_selector_role = "platform-observability"

}
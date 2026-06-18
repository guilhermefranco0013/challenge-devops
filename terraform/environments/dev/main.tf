# Namespace DEV.
#
# Responsável pela criação e gerenciamento
# do namespace de desenvolvimento.
module "dev_namespace" {
  source = "../../modules/namespace"

  namespace_name = "dev"

  labels = {
    environment = "dev"
    managed-by  = "terraform"
  }
}

# Governance DEV.
#
# Responsável pela aplicação de políticas
# de governança do namespace:
#
# - ResourceQuota
# - LimitRange
#
# Os valores foram definidos considerando
# o consumo atual do ambiente DEV.
module "dev_governance" {
  source = "../../modules/governance"

  namespace = "dev"

  requests_cpu    = "250m"
  requests_memory = "256Mi"

  limits_cpu    = "500m"
  limits_memory = "512Mi"

  default_cpu    = "100m"
  default_memory = "128Mi"

  max_cpu    = "500m"
  max_memory = "512Mi"
}

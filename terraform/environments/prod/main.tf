# Namespace PROD.
#
# Responsável pela criação e gerenciamento
# do namespace de desenvolvimento.
module "prod_namespace" {
  source = "../../modules/namespace"

  namespace_name = "prod"

  labels = {
    environment = "prod"
    managed-by  = "terraform"
  }
}

# Governance PROD.
#
# Responsável pela aplicação de políticas
# de governança do namespace:
#
# - ResourceQuota
# - LimitRange
#
# Os valores foram definidos considerando
# o consumo atual do ambiente PROD.
module "prod_governance" {
  source = "../../modules/governance"

  namespace = "prod"

  requests_cpu    = "3000m"
  requests_memory = "3072Mi"

  limits_cpu    = "4000m"
  limits_memory = "4096Mi"

  default_cpu    = "2000m"
  default_memory = "2048Mi"

  max_cpu    = "4000m"
  max_memory = "4096Mi"
}
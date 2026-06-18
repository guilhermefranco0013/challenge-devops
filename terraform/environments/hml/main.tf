# Namespace HML.
#
# Responsável pela criação e gerenciamento
# do namespace de desenvolvimento.
module "hml_namespace" {
  source = "../../modules/namespace"

  namespace_name = "hml"

  labels = {
    environment = "hml"
    managed-by  = "terraform"
  }
}

# Governance HML.
#
# Responsável pela aplicação de políticas
# de governança do namespace:
#
# - ResourceQuota
# - LimitRange
#
# Os valores foram definidos considerando
# o consumo atual do ambiente HML.
module "hml_governance" {
  source = "../../modules/governance"

  namespace = "hml"

  requests_cpu    = "1000m"
  requests_memory = "1024Mi"

  limits_cpu    = "2000m"
  limits_memory = "2048Mi"

  default_cpu    = "500m"
  default_memory = "512Mi"

  max_cpu    = "2000m"
  max_memory = "2048Mi"
}
# ------------------------------------------------------------------------------
# Sprint 5.4 - GHCR Pull Secret
# ------------------------------------------------------------------------------
#
# Cria um Secret Kubernetes do tipo docker-registry para autenticação
# no GitHub Container Registry.
#
# Este secret permite que os workloads do namespace consumam imagens
# privadas armazenadas no GHCR.
#
# Ownership: Terraform
# ------------------------------------------------------------------------------

resource "kubernetes_secret_v1" "ghcr_pull_secret" {
  count = var.enable_ghcr_secret ? 1 : 0

  metadata {
    name      = "ghcr-pull-secret"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "challenge-devops"
    }
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (var.ghcr_registry_server) = {
          username = var.ghcr_username
          password = var.ghcr_password
          auth     = base64encode("${var.ghcr_username}:${var.ghcr_password}")
        }
      }
    })
  }
}
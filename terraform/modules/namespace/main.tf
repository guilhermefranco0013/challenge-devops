# Cria um namespace Kubernetes.
#
# Este módulo é responsável por provisionar namespaces
# utilizados pelos ambientes da plataforma.
#
# Os namespaces são gerenciados exclusivamente pelo Terraform,
# seguindo os princípios definidos no SDD.
resource "kubernetes_namespace" "this" {
  metadata {
    name        = var.namespace_name
    labels      = var.labels
    annotations = var.annotations
  }

}
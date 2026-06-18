# Nome do namespace criado.
#
# Utilizado para validações,
# troubleshooting e integrações futuras.
output "namespace_name" {
  description = "The name of the created Kubernetes namespace."

  value = kubernetes_namespace.this.metadata[0].name

}

# UID do namespace criado.
#
# Utilizado para validações,
# troubleshooting e integrações futuras.
output "namespace_uid" {
  description = "The UID of the created Kubernetes namespace."

  value = kubernetes_namespace.this.metadata[0].uid

}
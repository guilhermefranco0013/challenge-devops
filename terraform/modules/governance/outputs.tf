# Nome do ResourceQuota criado.
#
# Utilizado para validações,
# troubleshooting e integrações futuras.
output "resource_quota_name" {
  description = "ResourceQuota name"

  value = kubernetes_resource_quota.this.metadata[0].name
}

# Nome do LimitRange criado.
#
# Utilizado para validações,
# troubleshooting e integrações futuras.
output "limit_range_name" {
  description = "LimitRange name"

  value = kubernetes_limit_range.this.metadata[0].name
}
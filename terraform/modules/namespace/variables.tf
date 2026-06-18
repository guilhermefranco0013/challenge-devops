# Nome do namespace Kubernetes.
#
# Exemplo:
# dev
# hml
# prod
# observability
# traefik
variable "namespace_name" {
  description = "The name of the Kubernetes namespace to create."
  type        = string

}

# Labels aplicadas ao namespace.
#
# Utilizadas para organização,
# governança e identificação dos ambientes.
variable "labels" {
  description = "Namespace labels"
  type        = map(string)

}

# Annotations aplicadas ao namespace.
#
# Utilizadas para integrações,
# metadados e futuras customizações.
variable "annotations" {
  description = "Namespace annotations"
  type        = map(string)

  default = {}

}
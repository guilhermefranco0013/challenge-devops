# Namespace onde os recursos de governança
# serão criados.
#
# Exemplo:
# dev
# hml
# prod
# observability
# traefik

variable "namespace" {
  description = "The namespace where the governance resources will be created."
  type        = string
}

# Quantidade total de CPU reservada
# para workloads do namespace.

variable "requests_cpu" {
  description = "The amount of CPU requested for the governance resources."
  type        = string

}

# Quantidade total de memória reservada
# para workloads do namespace.

variable "requests_memory" {
  description = "The amount of memory requested for the governance resources."
  type        = string
}

# Limite máximo agregado de CPU
# permitido dentro do namespace.

variable "limits_cpu" {
  description = "The amount of CPU limited for the governance resources."
  type        = string
}

# Limite máximo agregado de memória
# permitido dentro do namespace.

variable "limits_memory" {
  description = "The amount of memory limited for the governance resources."
  type        = string
}

# Valor padrão de CPU aplicado
# quando um container não define resources.

variable "default_cpu" {
  description = "The default amount of CPU for the governance resources."
  type        = string
}

# Valor padrão de memória aplicado
# quando um container não define resources.

variable "default_memory" {
  description = "The default amount of memory for the governance resources."
  type        = string
}

# Valor máximo de CPU permitido
# para um container individual.

variable "max_cpu" {
  description = "The maximum amount of CPU for the governance resources."
  type        = string
}

# Valor máximo de memória permitido
# para um container individual.

variable "max_memory" {
  description = "The maximum amount of memory for the governance resources."
  type        = string
}
# ResourceQuota controla o consumo agregado
# de recursos dentro do namespace.
#
# Objetivos:
# - Limitar CPU total do namespace.
# - Limitar memória total do namespace.
# - Limitar quantidade de Pods.
# - Evitar consumo excessivo da plataforma.
#
# Escopo:
# - Namespace completo
# - Não controla containers individualmente
#   (responsabilidade do LimitRange)

resource "kubernetes_resource_quota" "this" {
  metadata {
    #Nome padronizado do ResourceQuota.
    name = "${var.namespace}-quota"
    #Namespace onde o ResourceQuota será aplicado.
    namespace = var.namespace
  }

  spec {
    # Define os limites agregados do namespace.
    hard = {
      #Total de CPU reservada.
      "requests.cpu" = var.requests_cpu
      #Total de memória reservada.
      "requests.memory" = var.requests_memory

      #Limite máximo de CPU.
      "limits.cpu" = var.limits_cpu
      #Limite máximo de memória.
      "limits.memory" = var.limits_memory
      #Limite máximo de Pods.
      "pods" = "20"
    }
  }
}

# LimitRange define limites padrão e máximos
# para containers executados dentro do namespace.
#
# Objetivos:
# - Aplicar valores padrão quando resources não forem definidos.
# - Impedir containers com consumo excessivo.
# - Padronizar o uso de CPU e memória.
#
# Escopo:
# - Container individual
# - Não controla o consumo total do namespace
#   (responsabilidade do ResourceQuota)

resource "kubernetes_limit_range" "this" {
  metadata {
    #Nome padronizado do LimitRange.
    name = "${var.namespace}-limits"
    #Namespace onde o LimitRange será aplicado.
    namespace = var.namespace
  }

  spec {
    #Define os limites padrão e máximos para containers.
    limit {
      type = "Container"

      #Valores padrão aplicados quando resources não forem definidos.
      default = {
        cpu    = var.default_cpu
        memory = var.default_memory
      }

      #Valores máximos permitidos para containers individualmente.
      max = {
        cpu    = var.max_cpu
        memory = var.max_memory
      }
    }
  }
}


# ------------------------------------------------------------------------------
# Traefik
# ------------------------------------------------------------------------------
#
# Responsável pelo provisionamento do Ingress Controller da plataforma.
#
# O Traefik atua como camada de entrada da plataforma Kubernetes,
# sendo responsável pelo roteamento do tráfego entre usuários,
# aplicações e componentes compartilhados.
#
# Ownership:
# Terraform
#
# ADRs Relacionadas:
# - ADR-001
# - ADR-002
#
# ------------------------------------------------------------------------------
resource "helm_release" "traefik" {
  name      = "traefik"
  namespace = var.namespace

  repository = "https://traefik.github.io/charts"
  chart      = "traefik"

  version = var.traefik_chart_version

  wait    = false
  timeout = 600

  # ---------------------------------------------------------------------------
  # Deployment
  # ---------------------------------------------------------------------------
  #
  # Define a quantidade de réplicas do Ingress Controller.
  #
  # Em ambientes locais utilizando Kind uma única réplica é
  # suficiente, porém a configuração permanece parametrizada
  # para permitir escalabilidade futura.
  # ---------------------------------------------------------------------------
  set {
    name  = "deployment.replicas"
    value = var.replicas
  }

  # ---------------------------------------------------------------------------
  # Service
  # ---------------------------------------------------------------------------
  #
  # Mantém o serviço exposto como LoadBalancer.
  #
  # Em clusters Kind o balanceamento é realizado através
  # dos port mappings definidos na configuração do cluster.
  # ---------------------------------------------------------------------------
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  # ---------------------------------------------------------------------------
  # HTTP EntryPoint
  # ---------------------------------------------------------------------------
  #
  # Porta responsável pelo tráfego HTTP.
  #
  # Utilizada pelos ambientes DEV, HML e PROD para acesso
  # às aplicações através do Traefik.
  # ---------------------------------------------------------------------------
  set {
    name  = "ports.web.nodePort"
    value = var.web_node_port
  }

  # ---------------------------------------------------------------------------
  # HTTPS EntryPoint
  # ---------------------------------------------------------------------------
  #
  # Porta responsável pelo tráfego HTTPS.
  #
  # Mantida parametrizada para suportar futuras evoluções
  # relacionadas a TLS e certificados.
  # ---------------------------------------------------------------------------
  set {
    name  = "ports.websecure.nodePort"
    value = var.websecure_node_port
  }

  # ---------------------------------------------------------------------------
  # Scheduling
  # ---------------------------------------------------------------------------
  #
  # Garante que os pods do Traefik sejam executados apenas
  # nos nodes destinados aos componentes compartilhados
  # da plataforma.
  # ---------------------------------------------------------------------------

  set {
    name  = "nodeSelector.role"
    value = var.node_selector_role
  }
}

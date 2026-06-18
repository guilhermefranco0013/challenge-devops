# Namespace onde o Traefik será instalado.
variable "namespace" {
  description = "Namespace where Traefik will be installed."
  type        = string
}

# Versão do chart Helm do Traefik.
variable "traefik_chart_version" {
  description = "Traefik Helm charts version."
  type        = string
}

# Quantidade de réplicas.
variable "replicas" {
  description = "Number of traefik replicas."
  type        = number
}

# NodePort HTTP.
variable "web_node_port" {
  description = "NodePort for HTTP traffic."
  type        = number
}

# NodePort HTTPS.
variable "websecure_node_port" {
  description = "NodePort for HTTPS traffic."
  type        = number
}

# Node selector utilizado pelo Traefik.
variable "node_selector_role" {
  description = "Node Selector role"
  type        = string
}

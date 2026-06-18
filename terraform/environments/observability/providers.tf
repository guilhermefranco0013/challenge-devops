# Terraform Version Constraints
#
# Define as versões mínimas suportadas
# para o Terraform e seus providers.
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
  }
}

# Kubernetes Provider
#
# Responsável pela comunicação entre
# Terraform e o cluster Kubernetes.
#
# Nesta fase do projeto o provider utiliza
# o contexto local do Kind configurado
# através do arquivo kubeconfig.
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Helm Provider
#
# Responsável pelo gerenciamento de
# charts Helm no cluster Kubernetes.
provider "helm" {

  kubernetes {
    config_path = "~/.kube/config"
  }

}
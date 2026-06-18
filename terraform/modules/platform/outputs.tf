# Nome da release Helm do Traefik.
#
# Utilizado para validações,
# troubleshooting e integrações futuras.
output "traefik_release" {

  description = "The Traefik helm release name."

  value = helm_release.traefik.name

}


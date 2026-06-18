# Vision

## Context

O projeto challenge-devops possui uma plataforma Kubernetes funcional com CI/CD, DevSecOps e observabilidade implementados. Atualmente a entrega da aplicação é automatizada através de GitHub Actions e Helm, porém parte significativa da infraestrutura da plataforma ainda depende de configurações manuais.

## Problema

A ausência de Infrastructure as Code para recursos da plataforma reduz a reprodutibilidade do ambiente, aumenta a dependência de conhecimento operacional e dificulta a reconstrução completa da infraestrutura.

## Objetivo

Introduzir Terraform como camada oficial de provisionamento da plataforma, mantendo Helm responsável pela aplicação e GitHub Actions responsável pelos processos de integração, validação e promoção.

## Resultado Esperado

A plataforma deve ser reconstruível a partir de código, permitindo provisionamento consistente, auditável e reproduzível através de Terraform, enquanto a aplicação continua sendo entregue através de Helm e promovida através de GitHub Actions.

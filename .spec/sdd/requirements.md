Objetivo:
Definir os requisitos funcionais e não funcionais da introdução do Terraform.

Requisitos Funcionais

RF-001
O cluster Kubernetes deve ser provisionado através de Infrastructure as Code.

RF-002
Namespaces DEV, HML, PROD e OBSERVABILITY devem ser criados automaticamente.

RF-003
A plataforma de observabilidade deve ser instalada automaticamente.

Componentes:
Prometheus
Grafana
Tempo

RF-004
Traefik deve ser provisionado automaticamente.

RF-005
Resource Quotas devem existir para todos os namespaces.

RF-006
LimitRanges devem existir para todos os namespaces.

RF-007
Network Policies devem existir para todos os namespaces.

RF-008
GitHub Actions não deve criar infraestrutura.

RF-009
Helm não deve criar infraestrutura.

RF-010
Terraform deve ser a única fonte de verdade da plataforma.

Requisitos Não Funcionais

RNF-001
Infraestrutura deve ser reproduzível.

RNF-002
Infraestrutura deve ser idempotente.

RNF-003
Infraestrutura deve ser modular.

RNF-004
Infraestrutura deve ser versionada.

RNF-005
Infraestrutura deve suportar múltiplos ambientes.

OBS-004

Todos os componentes da stack de observabilidade devem
definir explicitamente requests e limits de CPU e memória.

Critério de Aceitação:

* Prometheus possui requests e limits.
* Grafana possui requests e limits.
* Tempo possui requests e limits.
* OpenTelemetry Collector possui requests e limits.
* ResourceQuota contabiliza consumo de recursos.

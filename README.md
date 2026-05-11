# Pulpit V2
### Multi-tenant sermon search platform on Amazon EKS

Pulpit V2 is the containerized, multi-tenant evolution of [Pulpit V1](https://github.com/manynames3/pulpit). V1 proved the product and low-cost serverless architecture. V2 exists to demonstrate Kubernetes, EKS, Terraform, Helm, ArgoCD, Prometheus, Grafana, OIDC, IRSA, and service decomposition in a real domain instead of a generic demo app.

**Status:** initial starter repository seeded from the V1 codebase and V2 architecture plan

## Goal

Build a production-style SaaS platform for bilingual church sermon search with:

- tenant isolation per church
- containerized ingest, query, and API services
- GitOps deployment flow
- metrics and dashboards that show business and platform behavior
- teardown-friendly infrastructure for portfolio demos

## V1 to V2

- **V1 repo:** [manynames3/pulpit](https://github.com/manynames3/pulpit)
- **V1 architecture:** static frontend + serverless AWS query backend + local ingest runner
- **V2 architecture:** EKS + microservices + Helm + ArgoCD + Prometheus/Grafana

This repository is not starting from zero. It is seeded from the current Pulpit codebase so the existing retrieval logic, AWS patterns, and ingest behavior can be migrated incrementally instead of rewritten blindly.

## Planned Architecture

### Services

- `ingest-service`
  - pulls YouTube captions
  - chunks sermons
  - generates embeddings through Bedrock Titan
  - stores sermon content and metadata
- `query-service`
  - receives natural-language questions
  - retrieves relevant chunks
  - calls Bedrock for cited answers
  - exposes Prometheus metrics
- `api-service`
  - auth/session edge
  - tenant-aware request routing
  - health and control endpoints for the platform

### Platform

- Amazon EKS
- Terraform
- Helm
- ArgoCD
- ECR
- IRSA
- External Secrets Operator
- AWS ALB Ingress Controller
- Prometheus, Grafana, Alertmanager

### Data and AI

- Amazon DynamoDB
- Amazon S3
- Amazon Bedrock
- Amazon Cognito

## Repository Layout

```text
pulpit-v2/
├── terraform/                  # V2 EKS and platform infrastructure
├── services/                   # Containerized FastAPI services
├── helm/                       # Helm chart and values
├── manifests/                  # GitOps and tenant manifests
├── docs/                       # Architecture and runbooks
├── frontend/                   # V1 reference code (seed material)
├── frontend-alternative/       # V1 reference code (seed material)
├── lambda/                     # V1 reference code (seed material)
├── modules/                    # V1 Terraform modules (seed material)
└── scripts/                    # Platform bootstrap helpers + V1 ingest/indexing reference
```

## Build Phases

### Phase 1 — Cluster and networking

- EKS cluster
- networking
- node groups
- ECR
- OIDC
- ALB ingress controller

### Phase 2 — Service containers

- FastAPI service containers
- non-root Dockerfiles
- GitHub Actions build/push flow

### Phase 3 — Kubernetes packaging

- Helm chart
- namespaces
- quotas
- HPA
- External Secrets

### Phase 4 — GitOps

- ArgoCD
- app-of-apps pattern
- tenant manifests

### Phase 5 — Observability

- kube-prometheus-stack
- Grafana dashboards
- Alertmanager rules
- cost and latency metrics

### Phase 6 — RAG migration

- move V1 retrieval logic into `query-service`
- move V1 ingest/indexing logic into `ingest-service`
- preserve bilingual search behavior

## Why a Separate Repository

V1 is a deployable working product. V2 is a platform and DevOps portfolio project. Keeping them separate:

- protects the live V1 deployment
- keeps the recruiter story clean
- isolates Terraform state and CI/CD
- allows aggressive infrastructure experiments without breaking the product demo

## Current Starter State

This repo now includes:

- V2 folder structure
- Terraform Phase 1 scaffold for VPC, ECR, EKS, and optional GitHub OIDC role setup
- starter FastAPI services with health endpoints
- starter Dockerfiles
- Helm chart with:
  - Deployments and Services for `api-service` and `query-service`
  - CronJob and metrics Service for `ingest-service`
  - ALB-style ingress
  - HPA for `query-service`
  - `ServiceMonitor` and `PrometheusRule` starters
  - IRSA-ready service account annotations
  - `ExternalSecret` support for tenant-scoped runtime configuration
- tenant manifests for:
  - `bethel-atlanta`
  - `demo-church`
- ArgoCD app-of-apps scaffolding for shared namespaces, tenant policies, and tenant workload apps
- starter Grafana dashboard artifact under `helm/observability`
- starter CI workflow for Terraform validation and container builds
- V2 architecture and runbook docs
- V1 code retained as migration reference

## Documentation

- [Architecture](docs/architecture.md)
- [Runbook](docs/runbook.md)
- [V1 migration notes](docs/v1-reference.md)
- [Platform bootstrap scripts](scripts/platform/README.md)

## Next Steps

1. Apply and verify the Phase 1 EKS stack
2. Install ArgoCD, External Secrets Operator, and kube-prometheus-stack into the cluster
3. Create tenant IRSA roles and SSM parameter paths
4. Validate the tenant apps and dashboard wiring end to end
5. Migrate V1 ingest and query logic into services

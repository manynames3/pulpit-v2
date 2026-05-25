# Pulpit V2

Validated EKS/GitOps platform migration of the working [Pulpit V1](https://github.com/manynames3/pulpit) serverless sermon search product.

Pulpit V1 proved the product: authenticated Korean-English sermon retrieval, cited answers, source cards, S3-backed indexes, Bedrock answer generation, cache invalidation, audit logging, and a low-idle-cost AWS serverless runtime. Pulpit V2 proves the platform migration path: Terraform-managed EKS, Helm-packaged services, ArgoCD app-of-apps, tenant namespaces, External Secrets backed by AWS SSM, IRSA-ready service accounts, ALB ingress, Prometheus/Grafana, CI validation, and teardown discipline.

**Positioning:** production-style AWS platform engineering work sample for EKS, GitOps, observability, security boundaries, and cost-aware operations.

- **Status:** validated short-lived EKS demo deployment; V2 query/ingest logic is still in migration
- **Live V2 frontend:** [pulpit-v2.pages.dev](https://pulpit-v2.pages.dev)
- **Latest deployment capture:** May 11, 2026
- **Deployment walkthrough:** [docs/deployment-walkthrough.md](docs/deployment-walkthrough.md)
- **Current migration boundary:** the live V2 frontend still bridges to the V1 API Gateway query/catalog backend while V1 retrieval behavior is migrated into `services/query-service`

## Validated Platform Deployment

This repo includes a completed live deployment capture of:

- Amazon EKS with a 2-node managed node group
- ArgoCD app-of-apps managing shared namespaces plus `bethel-atlanta` and `demo-church`
- internet-facing ALBs created from Kubernetes `Ingress`
- External Secrets backed by AWS Systems Manager Parameter Store
- Prometheus and Grafana scraping cluster components and tenant services
- a Cloudflare Pages frontend returning cited sermon search results through the V2 edge

<p align="center">
  <img src="docs/screenshots/v2/frontend/query-results-flood.png" alt="Pulpit V2 frontend returning cited sermon search results" width="32%" />
  <img src="docs/screenshots/v2/argocd/argocd-applications-overview.png" alt="ArgoCD applications overview for the V2 platform" width="32%" />
  <img src="docs/screenshots/v2/aws/eks-node-group-details.png" alt="Amazon EKS managed node group details" width="32%" />
</p>

More screenshots and notes are in the [deployment walkthrough](docs/deployment-walkthrough.md).

## Problem

Pulpit V1 is useful and cost-efficient as a serverless AWS application, but it does not show how the same domain workload would be packaged, governed, observed, and operated as a Kubernetes platform. A credible V2 migration needs to preserve V1 retrieval behavior while adding deployment discipline, tenant boundaries, GitOps ownership, observability, and teardown controls.

## Solution

Pulpit V2 keeps V1 as the proven product boundary while building the platform target around EKS. The V2 repo models the cluster, tenant workloads, GitOps sync, secrets delivery, metrics, dashboards, CI checks, and runbooks needed before the retrieval and ingestion code can safely cut over.

## Operational Value

- migration discipline instead of a risky rewrite
- tenant isolation through Kubernetes and AWS identity boundaries
- GitOps-based deployment ownership
- secrets and workload identity designed before production secrets are introduced
- platform metrics separated from future domain metrics
- cost-aware EKS usage with same-day teardown
- explicit gaps and cutover criteria

## V1 To V2 Migration Boundary

V1 remains the source of truth for product behavior until V2 passes retrieval and ingest acceptance criteria.

| Capability | V1 status | V2 status |
|---|---|---|
| Frontend | working Cloudflare Pages app | V2 Cloudflare Pages app live |
| Authenticated query/catalog | Cognito + API Gateway + Lambda | currently bridged through V1 backend |
| Retrieval | hybrid semantic + BM25-style lexical ranking | contract tests and migration docs added; implementation pending |
| Answers | Bedrock cited answers with source cards | preserved through V1 bridge |
| Ingestion | reliable local/church-network runner plus S3 index rebuild | EKS CronJob packaging exists; role should be indexing/enrichment handoff until OAuth captions API exists |
| Platform | serverless AWS, low idle cost | EKS/GitOps/Helm/observability platform validated |

The migration plan is in [docs/migration-roadmap.md](docs/migration-roadmap.md). Retrieval-specific acceptance criteria are in [docs/retrieval-quality-migration.md](docs/retrieval-quality-migration.md).

## What Was Proven

- A real EKS cluster can run the Pulpit V2 tenant workload shape.
- ArgoCD can sync root, shared, tenant-policy, and tenant workload applications.
- Helm renders per-tenant `api-service`, `query-service`, and `ingest-service` resources.
- Tenant namespaces, ResourceQuotas, LimitRanges, HPAs, CronJobs, Services, and Ingress resources are modeled.
- External Secrets can sync tenant app secrets from an AWS SSM-backed ClusterSecretStore.
- Prometheus can discover service targets and load Pulpit alert rules.
- Grafana can show live Kubernetes namespace/resource data.
- Cloudflare Pages can serve the V2 frontend while it bridges to the proven V1 query path.
- Teardown order matters and is documented so ALBs, nodes, and cluster resources do not linger.

See [docs/platform-evidence.md](docs/platform-evidence.md) for the evidence summary and current verification gaps.

## Implemented Platform Components

- `terraform/`: VPC, subnets, ECR repositories, EKS, managed node group, and GitHub Actions OIDC role scaffold.
- `helm/pulpit/`: Deployments, Services, Ingress, HPA, CronJob, ServiceAccount, ExternalSecret, ServiceMonitor, and PrometheusRule templates.
- `manifests/`: ArgoCD root/child apps, tenant namespaces, ResourceQuota, and LimitRange resources.
- `services/`: FastAPI service stubs with health, readiness, and Prometheus metrics endpoints.
- `.github/workflows/`: Terraform/Helm/manifest validation, service tests, Docker builds, and optional ECR publishing.
- `scripts/platform/`: ordered bootstrap scripts for ALB Controller, External Secrets, kube-prometheus-stack, ArgoCD, and health checks.
- `helm/observability/`: starter Grafana dashboard asset.
- `frontend-alternative/`: live V2 static frontend, currently configured to call the V1 API Gateway query/catalog endpoints.

## Tech Stack

| Layer | Tools |
|---|---|
| Cloud | AWS, Amazon EKS, ECR, IAM OIDC, ALB ingress target, SSM Parameter Store target |
| Infrastructure | Terraform modules under `terraform/` |
| Kubernetes | Helm, ArgoCD app-of-apps, namespaces, ResourceQuota, LimitRange, HPA, CronJob |
| Services | Python 3.12, FastAPI, Uvicorn, Prometheus client |
| Observability | Prometheus `ServiceMonitor`, `PrometheusRule`, Grafana dashboard starter |
| Frontend | Static Cloudflare Pages frontend |
| V1 bridge | API Gateway, Cognito, Lambda, S3, DynamoDB, Bedrock from Pulpit V1 |
| CI/CD | GitHub Actions for platform validation, service tests, Docker builds, optional ECR publish |

## Evidence Matrix

| Area | Evidence |
|---|---|
| IaC | `terraform/` modules for networking, ECR, EKS, IAM OIDC; Terraform fmt and validate workflow |
| CI/CD | `.github/workflows/ci.yml` for Terraform/Helm/manifests; `.github/workflows/build-push.yml` for tests, Docker builds, optional ECR publish |
| Security | IRSA-ready service accounts, External Secrets support, GitHub OIDC role, namespace boundaries, no plaintext app secrets in Helm values |
| Reliability | readiness/liveness probes, HPA for `query-service`, CronJob retry/history settings, deployment and teardown runbooks |
| Observability | service metrics endpoints, ServiceMonitor templates, PrometheusRule starters, Grafana screenshots, Grafana dashboard artifact |
| Cost | NAT disabled by default, short-lived EKS demo profile, explicit teardown order, ECR force delete for demo cleanup |
| Operations | [runbook](docs/runbook.md), [deployment](docs/deployment.md), [teardown](docs/teardown.md), [platform evidence](docs/platform-evidence.md) |
| Testing | FastAPI unit tests, Helm lint/template checks, static YAML parsing, Terraform fmt/validate, retrieval migration contract tests |
| Documentation | architecture, reviewer guide, ADRs, security, observability, cost model, tradeoffs, testing, migration roadmap |

## Architecture Overview

Pulpit V2 is a tenant-oriented EKS platform around the Pulpit domain workload:

- Cloudflare Pages serves the browser-facing frontend.
- During migration, frontend query/catalog requests bridge to the V1 API Gateway backend.
- EKS runs tenant-scoped API, query, and ingest service containers.
- ArgoCD owns platform and tenant desired state.
- External Secrets pulls runtime secrets from AWS SSM into Kubernetes.
- Prometheus and Grafana provide platform visibility.
- Terraform owns the AWS baseline: VPC, ECR, EKS, node group, and IAM/OIDC scaffolding.

See [docs/architecture.md](docs/architecture.md).

## Local Quickstart

From the repo root:

```bash
python3 -m venv /tmp/pulpit-v2-venv
source /tmp/pulpit-v2-venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r services/api-service/requirements.txt pytest httpx
PYTHONPATH=services/api-service pytest services/api-service/tests -q
```

Run a service locally:

```bash
PYTHONPATH=services/api-service uvicorn src.main:app --host 0.0.0.0 --port 8000
curl http://localhost:8000/healthz
curl http://localhost:8000/readyz
curl http://localhost:8000/metrics
```

Inspect the static frontend:

```bash
python3 -m http.server 8080 --directory frontend-alternative
```

## Test And Validation Commands

```bash
# Python service tests
PYTHONPATH=services/api-service pytest services/api-service/tests -q
PYTHONPATH=services/query-service pytest services/query-service/tests -q
PYTHONPATH=services/ingest-service pytest services/ingest-service/tests -q

# Retrieval migration contract
PYTHONPATH=services/query-service pytest services/query-service/tests/test_retrieval_contract.py -q

# Kubernetes packaging
helm lint helm/pulpit --values helm/pulpit/values-bethel-atlanta.yaml
helm template bethel-atlanta helm/pulpit --namespace bethel-atlanta --values helm/pulpit/values-bethel-atlanta.yaml

# Terraform validation
terraform -chdir=terraform init -backend=false
terraform fmt -check -recursive terraform
terraform -chdir=terraform validate

git diff --check
```

More detail is in [docs/testing.md](docs/testing.md).

## Deployment Overview

Pulpit V2 is designed for controlled demo deployments, not an always-on personal EKS cluster:

1. Run CI validation and review the Terraform plan.
2. Apply `terraform/` to create the VPC, ECR repositories, EKS cluster, and IAM/OIDC baseline.
3. Build and publish service images through GitHub Actions or local Docker/ECR commands.
4. Install cluster add-ons with [scripts/platform](scripts/platform/README.md): AWS Load Balancer Controller, ArgoCD, External Secrets Operator, and kube-prometheus-stack.
5. Apply the ArgoCD bootstrap manifests under `manifests/argocd/`.
6. Sync tenant apps and verify health, ingress, metrics, External Secrets, and teardown.

See [docs/deployment.md](docs/deployment.md) and the [live deployment walkthrough](docs/deployment-walkthrough.md).

## Ingestion Lesson From V1

V1 discovered that YouTube transcript scraping is unreliable from AWS IP ranges. V2 should not imply that moving ingestion into EKS automatically solves that. The credible paths are:

- trusted local/church-network caption collection plus platform-side validation, enrichment, embedding, and indexing, or
- official YouTube captions API access with OAuth consent from the channel owner.

Until the OAuth captions path exists, the EKS `ingest-service` should be treated as the indexing/enrichment/tenant handoff layer, not as proof that cloud-hosted caption scraping is solved.

## Security Model Summary

- GitHub Actions uses OIDC for AWS access instead of long-lived AWS keys.
- ECR publish permissions are scoped to repositories under the project prefix.
- Kubernetes workloads use IRSA-compatible service account annotations.
- Runtime secrets are modeled through External Secrets and SSM parameter paths.
- Tenant blast radius is reduced through namespaces, quotas, limits, and per-tenant values files.
- V2 auth and full JWT verification are not implemented in the FastAPI stubs yet; the current live query path relies on the V1 Cognito/API Gateway boundary.

See [docs/security.md](docs/security.md).

## Observability Model Summary

Current V2 observability proves Kubernetes/platform visibility:

- service health/readiness/metrics endpoints
- ServiceMonitor resources
- PrometheusRule starter alerts
- Grafana Kubernetes dashboards populated during the demo run

Future domain observability must include tenant query count, query latency, cache hit/miss, no-result rate, source count returned, Bedrock call count, ingest success/failure, indexed sermon count, and tenant request volume.

See [docs/observability.md](docs/observability.md).

## Cost Controls Summary

EKS and managed nodes exceed the low-idle budget if left running. Do not apply the EKS stack without approval for a short-lived demo window.

Current controls:

- NAT gateway disabled by default
- two-node `t3.medium` demo profile documented explicitly
- ECR repositories can be force deleted for cleanup
- teardown order documented to avoid orphaned ALBs and worker nodes
- V1 serverless backend and Cloudflare frontend preserve the low-idle production path during migration

See [docs/cost-model.md](docs/cost-model.md).

## Teardown And Cleanup Summary

The EKS demo should be torn down in dependency order:

1. capture final evidence
2. delete ArgoCD apps and ingress resources
3. wait for AWS Load Balancer Controller to delete ALBs and target groups
4. verify VPC dependencies are gone
5. run `terraform destroy`
6. confirm the EKS cluster, ALBs, nodes, and related demo resources are gone

See [docs/runbook.md](docs/runbook.md) and [docs/teardown.md](docs/teardown.md).

## Known Gaps

- V2 `query-service` does not yet implement V1 retrieval behavior.
- V2 `api-service` does not yet enforce Cognito JWT verification.
- The live V2 frontend currently calls V1 API Gateway endpoints directly.
- EKS `ingest-service` packaging exists, but cloud-hosted YouTube caption scraping is not considered solved.
- External Secrets, AWS Load Balancer Controller, ArgoCD, and kube-prometheus-stack installation are scripted or documented, not vendored.
- Domain metrics are still migration targets.
- The May 11, 2026 demo did not include a final successful Terraform destroy screenshot; the teardown lesson is documented from the failed first destroy attempt and follow-up cleanup guidance.

## What I Would Improve Next

1. Port V1 query planner, hybrid retrieval, synonym config, reranking, source snippets, caching, and audit behavior into `services/query-service`.
2. Move auth/session enforcement into `api-service`.
3. Reframe `ingest-service` around validated caption handoff, enrichment, embeddings, index rebuild, and tenant publication.
4. Add domain metrics and cutover smoke tests.
5. Add final teardown screenshots after the next approved short-lived deployment.
6. Cut over only after V2 passes the retrieval golden set and returns equivalent cited source cards.

## Repository Layout

```text
pulpit-v2/
├── terraform/                  # V2 EKS, networking, ECR, and IAM/OIDC infrastructure
├── services/                   # Containerized FastAPI services and V2 retrieval contract
├── helm/                       # Helm chart, tenant values, and observability starter assets
├── manifests/                  # ArgoCD app-of-apps, namespaces, quotas, and limits
├── docs/                       # Architecture, operations, security, cost, testing, migration docs, ADRs
├── scripts/                    # V1 ingest/indexing helpers and V2 platform bootstrap scripts
├── frontend-alternative/       # Live V2 static frontend, currently bridged to V1 API Gateway
├── frontend/                   # V1 frontend reference material
├── lambda/                     # V1 Lambda reference material
└── modules/                    # V1 Terraform module reference material
```

## Documentation

- [Architecture](docs/architecture.md)
- [Reviewer Guide](docs/reviewer-guide.md)
- [Live Deployment Walkthrough](docs/deployment-walkthrough.md)
- [Platform Evidence](docs/platform-evidence.md)
- [Migration Roadmap](docs/migration-roadmap.md)
- [Retrieval Quality Migration](docs/retrieval-quality-migration.md)
- [Deployment](docs/deployment.md)
- [Runbook](docs/runbook.md)
- [Security](docs/security.md)
- [Observability](docs/observability.md)
- [Cost Model](docs/cost-model.md)
- [Teardown](docs/teardown.md)
- [Tradeoffs](docs/tradeoffs.md)
- [Testing](docs/testing.md)
- [ADRs](docs/adrs/README.md)
- [V1 Migration Notes](docs/v1-reference.md)
- [Platform Bootstrap Scripts](scripts/platform/README.md)

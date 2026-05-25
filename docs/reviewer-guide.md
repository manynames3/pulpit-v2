# Reviewer Guide

## What To Look At First

If you have 10 minutes:

1. [README.md](../README.md) for the 60-second project story.
2. [architecture.md](architecture.md) for the system diagram and current-state boundaries.
3. `terraform/` for the V2 AWS platform scaffold.
4. `helm/pulpit/` for workload packaging, tenant values, External Secrets, IRSA, probes, HPA, and Prometheus resources.
5. `.github/workflows/` for validation, tests, Docker builds, and optional ECR publishing.
6. [security.md](security.md), [cost-model.md](cost-model.md), and [teardown.md](teardown.md) for operational ownership.

## What This Project Proves

This project shows platform engineering judgment around a real product migration:

- migrating a proven serverless V1 product into EKS/GitOps boundaries without hiding the bridge
- provisioning an EKS-oriented AWS baseline with Terraform modules
- packaging workloads with Helm and tenant values
- modeling GitOps with ArgoCD app-of-apps
- handling secrets through External Secrets instead of plaintext manifests
- planning workload identity with IRSA
- exposing metrics and Prometheus scrape resources
- documenting deployment, validation, teardown, cost controls, tradeoffs, and gaps honestly
- preserving V1 retrieval quality as a cutover requirement, not an afterthought

## File Map

| Reviewer question | Files |
|---|---|
| Where is the V2 infrastructure? | `terraform/main.tf`, `terraform/modules/*` |
| Where are the service containers? | `services/api-service`, `services/query-service`, `services/ingest-service` |
| Where are the Kubernetes workloads? | `helm/pulpit/templates/*`, `helm/pulpit/values*.yaml` |
| Where is GitOps modeled? | `manifests/argocd/*`, `manifests/argocd/applications/*` |
| Where are tenant boundaries? | `manifests/namespaces/*`, `manifests/tenants/*`, `helm/pulpit/values-*.yaml` |
| Where are observability assets? | `helm/pulpit/templates/servicemonitors.yaml`, `helm/pulpit/templates/prometheusrule.yaml`, `helm/observability/*` |
| Where are tests? | `services/*/tests/test_app.py` |
| Where is CI/CD? | `.github/workflows/ci.yml`, `.github/workflows/build-push.yml` |
| Where are operations docs? | `docs/runbook.md`, `docs/deployment.md`, `docs/teardown.md` |
| Where are tradeoffs and decisions? | `docs/tradeoffs.md`, `docs/adrs/README.md` |
| Where is the V1 bridge explained? | `README.md`, `docs/architecture.md`, `docs/migration-roadmap.md` |
| Where is retrieval migration quality defined? | `docs/retrieval-quality-migration.md`, `services/query-service/eval/retrieval-golden.json` |

## How To Run Or Inspect It

Run service tests:

```bash
PYTHONPATH=services/api-service pytest services/api-service/tests -q
PYTHONPATH=services/query-service pytest services/query-service/tests -q
PYTHONPATH=services/ingest-service pytest services/ingest-service/tests -q
```

Render the tenant chart:

```bash
helm lint helm/pulpit --values helm/pulpit/values-bethel-atlanta.yaml
helm template bethel-atlanta helm/pulpit --namespace bethel-atlanta --values helm/pulpit/values-bethel-atlanta.yaml
```

Validate Terraform without touching AWS:

```bash
terraform -chdir=terraform init -backend=false
terraform fmt -check -recursive terraform
terraform -chdir=terraform validate
```

Inspect the live static frontend:

```text
https://pulpit-v2.pages.dev
```

## Strongest Engineering Decisions

- The V2 work is separate from V1, which keeps the platform story clean and avoids breaking the original app.
- The live V2 frontend bridges to V1 during migration so product-quality retrieval is preserved while platform work proceeds.
- EKS is used intentionally because the goal is Kubernetes/platform evidence, not lowest possible hosting cost.
- The repo models tenant isolation through namespace and Helm boundaries instead of only application conditionals.
- External Secrets and IRSA are part of the workload contract early, before sensitive settings are introduced.
- Teardown is treated as part of operations, not an afterthought.

## Tradeoffs

- EKS is more expensive and operationally heavy than Lambda or ECS, but it demonstrates the requested platform skill set.
- Public nodes and disabled NAT reduce demo complexity and cost, but private nodes plus VPC endpoints would be a better production posture.
- Service logic is stubbed so the platform can be validated first; the V1 bridge preserves product behavior until migration work lands.
- Some cluster add-ons are documented rather than vendored to keep the repo small and avoid committing generated manifests.
- Mutable `latest` image tags are convenient for demo iteration but should be replaced by immutable digests or SHA tags in production.
- EKS `ingest-service` is framed as indexing/enrichment handoff until official YouTube captions API OAuth exists or local/church-network caption collection remains the source.

## Demo-Only Or Incomplete

- The EKS cluster is not expected to run continuously.
- V2 services do not yet implement full query, ingest, or Cognito JWT verification.
- The live V2 frontend currently calls V1 API Gateway query/catalog endpoints.
- External Secrets assumes a ClusterSecretStore exists in the cluster.
- Prometheus alerts and Grafana dashboards are starters.
- Platform evidence is summarized, but curated deployment screenshots are not yet committed.
- Root-level Terraform and V1 folders remain as migration reference, not the final V2 runtime.

## What Should Be Improved Next

1. Complete the query-service migration from V1 retrieval logic and pass the retrieval contract.
2. Complete the ingest-service migration as a validated caption handoff, enrichment, embedding, and index publication layer.
3. Add Cognito JWT verification and tenant authorization to `api-service`.
4. Create tenant workload IAM roles and SSM parameter bootstrap scripts.
5. Add a smoke test that runs against a short-lived demo cluster.
6. Capture real deployment evidence during an approved demo run.

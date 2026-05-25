# Migration Roadmap

## Summary

Pulpit V2 is a platform migration of a working V1 product. The goal is not to hide the bridge to V1. The goal is to move product behavior into the EKS platform without losing the retrieval quality, ingestion lessons, and cost discipline V1 already proved.

## Completed Platform Work

- Terraform scaffold for VPC, ECR, EKS, managed node groups, and GitHub Actions OIDC.
- Helm chart for API, query, and ingest workloads.
- per-tenant Helm values for `bethel-atlanta` and `demo-church`.
- tenant namespaces, quotas, and limits.
- ArgoCD app-of-apps manifests.
- ExternalSecret support backed by SSM parameter paths.
- IRSA-ready service accounts.
- ALB ingress templates and validated ingress creation.
- Prometheus ServiceMonitor and PrometheusRule templates.
- Grafana dashboard starter.
- CI validation for Terraform, Helm, manifests, service tests, Docker builds, and optional ECR publish.
- deployment, security, observability, cost, teardown, tradeoff, and reviewer docs.

## Current Bridge To V1

The live V2 frontend currently calls V1 API Gateway endpoints for:

- `POST /query`
- `GET /catalog`

This preserves:

- authenticated access through V1 Cognito/API Gateway.
- V1 hybrid retrieval behavior.
- Bedrock cited answer generation.
- source cards and snippets.
- S3 index/cache/audit behavior.

This bridge should remain until V2 passes cutover criteria.

## Retrieval Migration

Move from V1 `lambda/query/query_service.py` into V2 `services/query-service`:

- bilingual query planning.
- semantic + lexical hybrid retrieval.
- BM25-style field scoring.
- synonym/crosswalk config.
- Korean morphology-aware matching.
- per-subquery retrieval and candidate union.
- neighbor chunk expansion.
- reranking.
- source snippets and source-card payloads.
- cache invalidation tied to index markers.
- query audit records.
- golden-query evaluation.

Acceptance criteria are in [retrieval-quality-migration.md](retrieval-quality-migration.md).

## Ingestion Migration

Do not simply move YouTube scraping into EKS. V1 already discovered that AWS IP ranges are unreliable for transcript scraping.

Credible migration paths:

- keep trusted local/church-network caption collection and use EKS for validation, enrichment, embeddings, and tenant index publication.
- or implement official YouTube captions API access with OAuth consent from the channel owner.

V2 `ingest-service` should become the platform handoff layer for validated captions until the OAuth captions path exists.

## Observability Hardening

Current metrics are platform-focused. Add domain metrics before cutover:

- query count by tenant.
- query latency.
- cache hit/miss.
- no-result rate.
- source count returned.
- Bedrock call count.
- ingest success/failure.
- indexed sermon count.
- tenant request volume.

Then connect those metrics to Grafana dashboards and alert rules.

## Tenant And Security Hardening

Before production-style cutover:

- implement Cognito JWT verification in `api-service`.
- enforce tenant context before index selection.
- create tenant-specific workload IAM roles.
- restrict SSM parameter paths per tenant.
- add NetworkPolicies if the CNI and cluster policy support them.
- use immutable image tags or digests.
- restrict public access and endpoint CIDRs for non-demo environments.
- document audit retention and incident review paths.

## Cutover Criteria

V2 can replace the V1 query backend only when:

1. retrieval contract tests pass.
2. golden queries return equivalent or better source evidence than V1.
3. V2 source cards match frontend expectations.
4. V2 auth/tenant checks are implemented.
5. cache invalidation is index-aware.
6. query/audit logging exists.
7. domain metrics are emitted.
8. rollback to V1 is documented and tested.
9. ingestion handoff is operationally reliable.
10. teardown and cost checks remain documented.

## Post-Cutover Improvements

- add automated deployed smoke tests.
- add load and latency budgets.
- add OpenTelemetry tracing if cross-service latency becomes hard to diagnose.
- consider a dedicated retrieval backend only if archive size or query volume justifies the cost.
- commit curated platform evidence screenshots.

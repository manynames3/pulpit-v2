# Observability

## Summary

Pulpit V2 currently proves Kubernetes and platform observability. Product/domain observability still needs to be migrated from the V1 query path into V2 services.

The split matters: seeing EKS namespaces in Grafana is platform evidence; knowing whether sermon retrieval is useful requires domain metrics.

## Current Platform Metrics

Implemented or validated:

| Signal | Current implementation |
|---|---|
| Health | `/healthz` on each FastAPI service |
| Readiness | `/readyz` on each FastAPI service |
| Service metrics | `/metrics` Prometheus endpoint on each service |
| Scraping | Helm `ServiceMonitor` resources |
| Alerts | Helm `PrometheusRule` starter |
| Dashboard | `helm/observability/dashboards/pulpit-v2-overview.json` plus validated Grafana Kubernetes dashboards |
| Job health | ingest CronJob plus planned kube-state-metrics alerts |
| Cluster state | kube-prometheus-stack and kube-state-metrics during the demo run |

Current service metric names:

- `pulpit_api_requests_total`
- `pulpit_query_requests_total`
- `pulpit_query_request_latency_seconds`
- `pulpit_ingest_requests_total`

## Validated During The Demo Run

The May 11, 2026 evidence set showed:

- kube-prometheus-stack running in the `observability` namespace.
- Grafana reachable through port-forward.
- Grafana Kubernetes dashboards populated with CPU, memory, network, and namespace data.
- Prometheus loaded tenant alert rule groups for Pulpit availability and ingest failures.
- metrics were visible by namespace, including `argocd`, `bethel-atlanta`, `demo-church`, `external-secrets`, `kube-system`, and `observability`.

This proves the platform observability path. It does not prove domain retrieval quality or production alerting.

## Future Domain Metrics

Before V2 cutover from the V1 query backend, add:

- query count by tenant.
- query latency.
- cache hit/miss.
- no-result rate.
- source count returned.
- Bedrock call count.
- planner/reranker/answer latency.
- ingest success/failure.
- indexed sermon count.
- tenant request volume.
- retrieval candidate count.
- source-snippet coverage.

These metrics should be emitted by `api-service`, `query-service`, and `ingest-service` with tenant labels that avoid exposing private user data.

## Prometheus Model

The Helm chart renders ServiceMonitor resources for:

- `api-service`
- `query-service`
- `ingest-service` metrics service

The chart assumes kube-prometheus-stack or compatible CRDs are installed in the cluster. It does not vendor the operator.

## Alert Model

Starter alerts currently cover:

- API service scrape failure.
- query service scrape failure.
- query p95 latency above a configured threshold.
- ingest CronJob failures.

Production hardening should add:

- tenant no-result rate threshold.
- V1 bridge failure or V2 upstream failure.
- Bedrock error rate.
- cache error rate.
- ExternalSecret sync failure.
- ArgoCD app degraded/out-of-sync.
- ALB target health.
- budget/cost anomaly alarms outside the cluster.

## Dashboard Model

Current dashboard assets should be treated as starters. A reviewer should expect:

- platform panels for namespace CPU/memory/network, pod readiness, HPA, and CronJobs.
- tenant panels for request volume, latency, error rate, no-result rate, source count, Bedrock calls, and ingest status after migration.

## Logging

Current service stubs rely on default application/runtime logging. Production logging should add:

- request IDs.
- tenant ID.
- route and status code.
- upstream timing.
- sanitized error class.
- retrieval outcome summary.
- no JWTs, API keys, raw secrets, or sensitive transcript payloads.

V1 already records query/audit information in DynamoDB. V2 should preserve equivalent auditability before cutover.

## Tracing

Distributed tracing is not implemented. A production version should add OpenTelemetry instrumentation across:

- Cloudflare/API ingress boundary.
- `api-service`.
- `query-service`.
- Bedrock calls.
- S3/DynamoDB access.
- ingest job runs.

## Operational Review Checklist

Before presenting a live demo, verify:

- Prometheus targets are up.
- ServiceMonitor resources are selected by the Prometheus release.
- PrometheusRule resources are loaded.
- Grafana can read the Prometheus data source.
- each service returns `/healthz`, `/readyz`, and `/metrics`.
- at least one dashboard panel has current data.
- ingest CronJob state is visible through kube-state-metrics.
- V1 bridge health is checked if the frontend is still using V1 query/catalog endpoints.

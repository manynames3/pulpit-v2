# Observability Helm Assets

This directory is reserved for observability-related Helm values or wrappers, such as:

- kube-prometheus-stack values
- Grafana dashboard ConfigMaps
- Alertmanager rule values

Starter assets included here:

- `dashboards/pulpit-v2-overview.json`
  - example Grafana dashboard covering request volume, query latency, ingest completions, and Bedrock token estimates
- the application chart under `../pulpit` now includes:
  - `ServiceMonitor` resources for `api-service`, `query-service`, and `ingest-service`
  - a `PrometheusRule` starter with availability, latency, and ingest-failure alerts

# Platform Evidence

## Summary

Pulpit V2 has evidence from a short-lived EKS deployment run on May 11, 2026. The screenshots for that run were reviewed locally during this update but are not yet committed as curated repo assets. This page summarizes what the evidence shows and what still needs to be made public for third-party verification.

## Validated Platform Deployment

The May 11, 2026 evidence set shows:

- EKS cluster `pulpit-v2-dev-eks` active.
- Kubernetes version `1.35`.
- two `t3.medium` managed node group workers.
- two Ready nodes from `kubectl get nodes -o wide`.
- namespaces for `argocd`, `bethel-atlanta`, `demo-church`, `external-secrets`, `observability`, and `kube-system`.
- running tenant workloads for `bethel-atlanta` and `demo-church`.
- AWS Load Balancer Controller running in `kube-system`.
- ArgoCD root application healthy and synced.
- child ArgoCD applications for `bethel-atlanta`, `demo-church`, `shared-namespaces`, and `tenant-policies`.
- ResourceQuota and LimitRange resources synced through tenant policies.
- `ExternalSecret` resources for both tenants with `SecretSynced` status.
- ClusterSecretStore `aws-parameter-store` valid, read/write capable, and ready.
- ALB hosts created from Kubernetes Ingress for tenant API services.
- kube-prometheus-stack, Prometheus, Alertmanager, kube-state-metrics, and Grafana running.
- Prometheus targets discovered for cluster and service monitoring.
- Grafana Kubernetes dashboards populated with namespace CPU, memory, and network data.
- Prometheus loaded Pulpit alert rule groups for tenant availability and ingest failures.
- Cloudflare Pages deployment for `pulpit-v2.pages.dev`.
- V2 frontend returned a cited answer with source cards while bridged to the V1 API Gateway query path.

## What This Proves

The evidence proves the platform layer can be deployed and observed:

- EKS and managed nodes can host the workload shape.
- ArgoCD can sync shared and tenant resources from Git.
- tenant namespaces can run separate API, query, and ingest workloads.
- External Secrets can bridge AWS SSM configuration into Kubernetes.
- ALB ingress can expose tenant APIs.
- Prometheus and Grafana can discover and visualize cluster/platform signals.
- the V2 frontend can preserve product behavior through the V1 bridge during migration.

## What It Does Not Prove

The evidence does not prove:

- V2 `query-service` has replaced V1 retrieval.
- V2 `api-service` enforces Cognito JWTs.
- EKS solves YouTube transcript collection.
- the EKS stack is currently running.
- production uptime, production user traffic, or production support maturity.
- domain metrics such as no-result rate, cache hit rate, source count returned, or Bedrock call count.

## Evidence To Commit Next

For public reviewer verification, curate and commit screenshots under `docs/screenshots/v2/`:

- EKS cluster overview.
- managed node group details.
- `kubectl get nodes -o wide`.
- `kubectl get pods -A`.
- `kubectl get ingress -A -o wide`.
- ArgoCD root application.
- ArgoCD tenant policy application.
- ExternalSecret tenant state.
- ClusterSecretStore state.
- Grafana Kubernetes dashboard.
- Prometheus rules or targets.
- Cloudflare Pages deployment.
- V2 frontend cited answer with source cards.
- Terraform destroy success or AWS resource absence after teardown.

## Teardown Lesson

The deployment evidence reinforced that teardown order matters. Kubernetes Ingress and ArgoCD-managed workloads should be removed before destroying Terraform-managed infrastructure so the AWS Load Balancer Controller can clean up ALBs and dependent AWS resources.

The teardown flow is documented in [teardown.md](teardown.md).

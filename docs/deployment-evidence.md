# Pulpit V2 Deployment Evidence Template

This page is the capture template for a V2 deployment evidence run. It is not proof by itself. Add dated screenshots, command output, and notes here only after an approved live EKS demo has actually been provisioned, observed, and torn down.

## What this page should prove after a real run

A reviewer should be able to verify that:

- Terraform created a real EKS environment
- workloads ran in Kubernetes namespaces
- GitOps was used through ArgoCD
- observability was configured through Prometheus and Grafana
- secrets and workload identity were handled through External Secrets and IRSA
- the V2 frontend was reachable and usable
- any demonstrated query/answer behavior used the documented V1 bridge unless V2 cutover evidence is added
- the environment was intentionally destroyed to control cost

## Infrastructure Evidence

Include screenshots for:

- EKS cluster overview
- managed node group overview
- `kubectl get nodes`
- ALB present in AWS Console or `kubectl get ingress -A`

What should be visible:

- cluster name
- region
- node count
- Ready node state

## Kubernetes Workload Evidence

Include screenshots for:

- `kubectl get pods -A`
- `kubectl get ns`
- `kubectl get svc -A`
- `kubectl get hpa -A`
- `kubectl get cronjob -A`

What should be visible:

- `argocd`, `observability`, `bethel-atlanta`, and `demo-church` namespaces
- Running workloads
- HPA for `query-service`
- CronJob for `ingest-service`

## GitOps Evidence

Include screenshots for:

- ArgoCD applications overview
- ArgoCD root application
- one tenant application detail page
- sync or revision history if available

What should be visible:

- GitHub repo URL
- branch or revision
- `Synced`
- `Healthy`

## Observability Evidence

Include screenshots for:

- Grafana overview dashboard
- Prometheus targets page
- one latency panel
- one request-volume panel
- one ingest or job-health panel

What should be visible:

- live data
- namespace or tenant selection
- scrape success

## Security and Secret Handling Evidence

Include screenshots for:

- ServiceAccount showing IRSA annotation
- ExternalSecret resource
- SecretStore or ClusterSecretStore
- IAM role page if useful

What should be visible:

- `eks.amazonaws.com/role-arn`
- `ExternalSecret`
- no plaintext application secrets in manifests

## Application Evidence

Include screenshots for:

- live V2 frontend on Cloudflare Pages
- one successful query result
- one cited or source-backed response
- optional bilingual toggle proof

Label the query path clearly:

- `V1 bridge` if the frontend called the existing V1 API Gateway endpoints
- `V2 query-service` only after V2 retrieval has actually replaced the V1 backend

## Cost Control Evidence

Include screenshots for:

- Terraform destroy success
- EKS cluster absence after destroy if useful

This matters because the V2 stack is a short-lived portfolio environment, not an always-on production system.

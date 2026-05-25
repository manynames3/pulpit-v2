# Deployment

## Summary

Pulpit V2 is deployed as a controlled demo platform:

- Cloudflare Pages hosts the static frontend.
- Terraform creates the AWS/EKS foundation.
- GitHub Actions can build service images and optionally publish them to ECR.
- ArgoCD syncs Kubernetes manifests and Helm releases into the cluster.

The EKS deployment should be treated as short-lived unless a separate cost approval exists. The live V2 frontend currently bridges to V1 API Gateway for query/catalog behavior during migration.

## Preconditions

Local tools:

- `aws`
- `terraform`
- `kubectl`
- `helm`
- `argocd` for interactive ArgoCD operations
- Docker if building images locally

AWS prerequisites:

- credentials for the intended account and region
- permission to create VPC, ECR, EKS, IAM, EC2, and load balancer resources
- approval for costs above `$0.50/day`

Repository prerequisites:

- service tests pass
- Terraform validates
- Helm chart lints and renders
- no secrets are committed

## Validate Before Apply

```bash
terraform -chdir=terraform init -backend=false
terraform fmt -check -recursive terraform
terraform -chdir=terraform validate
helm lint helm/pulpit --values helm/pulpit/values-bethel-atlanta.yaml
helm lint helm/pulpit --values helm/pulpit/values-demo-church.yaml
```

## Terraform Plan

```bash
terraform -chdir=terraform init
terraform -chdir=terraform plan -var-file=environments/dev/dev.tfvars
```

Review the plan for:

- one EKS cluster
- expected managed node group size
- no NAT gateway unless intentionally approved
- ECR repositories for the three services
- GitHub Actions OIDC role and policy scope

## Terraform Apply

Only run apply inside an approved demo window:

```bash
terraform -chdir=terraform apply -var-file=environments/dev/dev.tfvars
```

After apply:

```bash
aws eks update-kubeconfig --region us-east-1 --name pulpit-v2-dev-eks
kubectl get nodes
kubectl get ns
```

## Build And Publish Images

The `Build Images` workflow runs tests and Docker builds. ECR publish is optional and gated by repository variables:

- `AWS_ROLE_TO_ASSUME`
- `ENABLE_ECR_PUBLISH=true`

The publish job uses GitHub OIDC, not static AWS keys.

Images are pushed with both the commit SHA tag and `latest`. For production, prefer immutable SHA tags or digests in Helm values.

## Cluster Add-Ons

Install or verify these add-ons before syncing tenant workloads:

- AWS Load Balancer Controller
- ArgoCD
- External Secrets Operator
- kube-prometheus-stack

These add-ons are not vendored into the repo. Document exact install versions during a real deployment evidence run.

## GitOps Bootstrap

Apply the ArgoCD bootstrap manifests:

```bash
kubectl apply -f manifests/namespaces/argocd.yaml
kubectl apply -f manifests/argocd/project.yaml
kubectl apply -f manifests/argocd/root-application.yaml
```

Then verify child applications:

```bash
kubectl get applications -n argocd
```

Expected application groups:

- shared namespaces
- tenant policies
- `bethel-atlanta`
- `demo-church`

## Tenant Verification

Verify Kubernetes resources:

```bash
kubectl get ns
kubectl get resourcequota -A
kubectl get limitrange -A
kubectl get pods -A
kubectl get ingress -A
kubectl get hpa -A
kubectl get cronjob -A
```

Verify service endpoints:

```bash
kubectl -n bethel-atlanta port-forward svc/bethel-atlanta-pulpit-api 8080:80
curl http://localhost:8080/healthz
curl http://localhost:8080/metrics
```

Service names depend on Helm release names; confirm with `kubectl get svc -n bethel-atlanta`.

## Frontend Integration

The live static frontend is hosted at:

```text
https://pulpit-v2.pages.dev
```

Current migration state:

- the V2 frontend is live on Cloudflare Pages.
- `frontend-alternative/index.html` calls the V1 API Gateway `/query` and `/catalog` endpoints.
- this preserves V1 retrieval quality while V2 platform services are migrated.

Do not claim the EKS `query-service` has replaced V1 until the bridge is removed and the cutover criteria in [migration-roadmap.md](migration-roadmap.md) pass.

## Rollback

Kubernetes rollback:

- revert the Git commit or Helm values that caused the issue
- let ArgoCD sync the previous desired state
- use ArgoCD history only as an operational aid; Git remains the source of truth

Image rollback:

- use a previous commit SHA image tag
- avoid relying on `latest` for production rollback

Infrastructure rollback:

- prefer forward fixes for Terraform-managed resources
- review `terraform plan` before any corrective apply

## Evidence Capture

Use [deployment-evidence.md](deployment-evidence.md) and [screenshot-shot-list.md](screenshot-shot-list.md) during the live demo window.

Capture:

- Terraform apply or plan evidence
- EKS cluster and nodes
- ArgoCD synced apps
- tenant pods, ingress, HPA, and CronJob
- Prometheus targets
- Grafana dashboard data
- ExternalSecret and IRSA annotations
- Terraform destroy completion

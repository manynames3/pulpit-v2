# Pulpit V2 Runbook

## Purpose

This runbook supports a short-lived EKS demo session for Pulpit V2. The goal is to create the platform, verify the Kubernetes and observability surfaces, capture evidence, and tear everything down before costs drift.

The current V2 services are health/metrics stubs. The live V2 frontend bridges to V1 API Gateway for query/catalog behavior. Do not treat a successful platform run as proof that full sermon query and ingest behavior has been migrated.

## Demo Profile

Default demo shape:

- one EKS cluster
- two `t3.medium` worker nodes
- internet-facing ALBs if tenant ingress is enabled
- NAT gateway disabled by default
- AWS Load Balancer Controller installed as a cluster add-on
- ArgoCD installed manually or by an approved bootstrap step
- External Secrets Operator installed manually or by an approved bootstrap step
- kube-prometheus-stack installed manually or by an approved bootstrap step
- tenant namespaces for `bethel-atlanta` and `demo-church`

Do not start this environment without approval for costs above `$0.50/day`.

## Demo-Day Sequence

1. Apply the dev Terraform profile.
2. Run the platform bootstrap scripts.
3. Verify AWS, `kubectl`, ArgoCD, Prometheus, and Grafana state.
4. Verify the V1 bridge if the live frontend is used.
5. Capture screenshots and command evidence.
6. Remove Kubernetes resources that create AWS resources outside Terraform.
7. Run `terraform destroy`.
8. Verify the cluster and ALBs are gone.

## Preflight

Before applying Terraform:

- confirm AWS account and region
- confirm the demo window and teardown owner
- run service tests
- run Terraform validation
- run Helm lint/template checks
- review `terraform plan`
- confirm no secrets are in the working tree
- confirm screenshots/evidence destination

## Launch Sequence

### 1. Infrastructure

```bash
terraform -chdir=terraform init
terraform -chdir=terraform plan -var-file=environments/dev/dev.tfvars
terraform -chdir=terraform apply -var-file=environments/dev/dev.tfvars
```

Verify:

```bash
aws eks update-kubeconfig --region us-east-1 --name pulpit-v2-dev-eks
kubectl get nodes
kubectl get ns
```

Expected:

- EKS cluster exists
- two worker nodes are Ready
- no unexpected NAT gateway if using the default dev profile

### 2. Shared Platform Bootstrap

The platform bootstrap order is documented in [`../scripts/platform/README.md`](../scripts/platform/README.md).

At a minimum, install or verify:

- AWS Load Balancer Controller
- ArgoCD
- External Secrets Operator
- kube-prometheus-stack

The end-to-end helper is:

```bash
scripts/platform/90-bootstrap-demo-platform.sh
```

Verify:

```bash
kubectl get pods -A
kubectl get svc -A
kubectl get crd | grep -E 'servicemonitors|prometheusrules|externalsecrets|applications'
```

### 3. GitOps Bootstrap

```bash
kubectl apply -f manifests/namespaces/argocd.yaml
kubectl apply -f manifests/argocd/project.yaml
kubectl apply -f manifests/argocd/root-application.yaml
```

Verify:

```bash
kubectl get applications -n argocd
```

Expected child apps:

- shared namespaces
- tenant policies
- `bethel-atlanta`
- `demo-church`

### 4. Tenant Workloads

Verify:

```bash
kubectl get ns bethel-atlanta demo-church
kubectl get resourcequota -A
kubectl get limitrange -A
kubectl get pods -A
kubectl get ingress -A
kubectl get hpa -A
kubectl get cronjob -A
```

A healthy session should show:

- two Ready worker nodes
- ArgoCD applications in `Synced / Healthy`
- tenant `ExternalSecret` objects in `SecretSynced / Ready=True`
- Prometheus targets in `UP`
- a working Cloudflare Pages frontend path returning archive results through the V1 bridge

### 5. Service Health

Port-forward to the API service after confirming the rendered service name:

```bash
kubectl get svc -n bethel-atlanta
kubectl -n bethel-atlanta port-forward svc/<api-service-name> 8080:80
curl http://localhost:8080/healthz
curl http://localhost:8080/readyz
curl http://localhost:8080/metrics
```

Expected:

- health returns `ok`
- readiness returns `ready`
- metrics include the Pulpit service counter

### 6. Bridge Verification

If using the live V2 frontend during migration:

- open `https://pulpit-v2.pages.dev`
- verify browser requests still target the expected V1 API Gateway query/catalog endpoints
- verify cited answers and source cards still render through the bridge
- record that this proves bridge continuity, not V2 query-service cutover

## Troubleshooting

| Symptom | Likely cause | First checks |
|---|---|---|
| nodes not Ready | node group bootstrap, subnet, IAM, or CNI issue | `kubectl describe node`, EKS node group events |
| ingress has no address | AWS Load Balancer Controller missing or misconfigured | controller logs, subnet tags, ingress annotations |
| ExternalSecret not ready | missing ClusterSecretStore, SSM path, or IAM permission | `kubectl describe externalsecret`, operator logs |
| ArgoCD app OutOfSync | manifest drift or Helm render failure | ArgoCD app events and rendered manifests |
| Prometheus target down | ServiceMonitor label mismatch or service port mismatch | Prometheus targets page, ServiceMonitor labels |
| HPA unknown metrics | metrics-server missing or not ready | `kubectl top pods`, metrics-server logs |
| Terraform destroy blocked | ALB/ENI/security group dependency remains | delete ingress first, inspect ELB/EC2 dependencies |
| V2 frontend query fails | V1 API Gateway/Cognito issue or bridge URL mismatch | browser console, V1 API health, configured frontend URLs |

## Rollback

Kubernetes:

- revert the Git commit or Helm values change
- let ArgoCD sync the previous desired state
- use `kubectl rollout status` to verify deployment health

Images:

- prefer commit SHA tags from the build workflow
- avoid using `latest` for production rollback decisions

Terraform:

- review `terraform plan` before corrective changes
- prefer forward fixes instead of manual console edits

## Evidence Checklist

Capture during an approved demo window:

- Terraform plan or apply evidence
- EKS cluster overview
- managed node group details
- `kubectl get nodes`
- `kubectl get pods -A`
- `kubectl get ingress -A`
- ArgoCD applications overview
- tenant app details
- Prometheus targets
- Grafana dashboard with live data
- ExternalSecret resource state
- service account IRSA annotation
- ECR repositories or image tags
- Terraform destroy success

Use [deployment-evidence.md](deployment-evidence.md), [deployment-walkthrough.md](deployment-walkthrough.md), and [screenshot-shot-list.md](screenshot-shot-list.md).

## Success Criteria

A platform demo run is complete when:

- Terraform created the expected AWS resources
- two nodes reached Ready
- ArgoCD synced the expected apps
- tenant workloads reached a healthy state
- service health and metrics endpoints responded
- V1 bridge behavior is explicitly recorded if the frontend query path is demonstrated
- Prometheus scraped at least one service target
- required evidence was captured
- teardown completed and AWS leftovers were checked

## Teardown

The cluster profile in this repo is intentionally demo-oriented. The environment should not be left running after screenshots and verification are complete.

### Pre-Teardown Checklist

Before running `terraform destroy`, complete these steps:

1. Capture the remaining screenshots you want to keep.
2. Confirm the frontend, ArgoCD, and observability pages are no longer needed.
3. Remove Kubernetes resources that create AWS resources outside Terraform.
4. Wait for the AWS Load Balancer Controller to delete its ALBs and target groups.
5. Verify the VPC no longer has ALB-owned dependencies.

The critical point is step 3. The ALBs in this environment are created by Kubernetes `Ingress` objects through the AWS Load Balancer Controller. Terraform did not create those ALBs directly, so Terraform cannot cleanly delete the VPC while they still exist.

### 1. Remove Ingress-Driven Tenant Resources

Use either ArgoCD or direct Kubernetes deletes. For a short-lived demo, direct deletion is the fastest approach.

Check current ingress objects:

```bash
kubectl get ingress -A
```

Delete them:

```bash
kubectl delete ingress --all -A
```

If you want to fully unwind tenant workloads before infra destroy, also remove the tenant apps from ArgoCD or delete the tenant namespaces after screenshots are complete.

### 2. Wait For AWS Load Balancer Controller Cleanup

Poll until the `k8s-...` ALBs are gone:

```bash
aws elbv2 describe-load-balancers --region us-east-1
aws elbv2 describe-target-groups --region us-east-1
```

The safe state is:

- no tenant ALBs remain
- no tenant target groups remain

### 3. Verify No VPC Dependencies Remain

The first failed destroy on May 11, 2026 happened because ALB-created ENIs, public IP mappings, target groups, and security groups still existed in the VPC after the EKS cluster had already been removed.

Use the VPC id from the active Terraform output:

```bash
VPC_ID=$(terraform -chdir=terraform output -raw vpc_id)

aws ec2 describe-network-interfaces \
  --region us-east-1 \
  --filters Name=vpc-id,Values="${VPC_ID}"

aws ec2 describe-security-groups \
  --region us-east-1 \
  --filters Name=vpc-id,Values="${VPC_ID}"
```

If Terraform outputs are unavailable during incident recovery, use the VPC id from the AWS console or the failed destroy logs. The May 11, 2026 demo failure involved `vpc-025711caee3a89b53`.

If ALB-related ENIs or security groups still exist, wait longer or delete the orphaned ALBs first. Do not rerun `terraform destroy` until the VPC is clear.

### 4. Destroy The Terraform-Managed Stack

Run destroy from the repo root:

```bash
terraform -chdir=terraform destroy -var-file=environments/dev/dev.tfvars
```

Capture a screenshot of:

- the destroy command
- the final `Destroy complete!` line
- the resource count summary

## Failure Mode: Why Destroy Can Fail

If destroy errors look like this:

- `DependencyViolation` deleting a subnet
- `mapped public address(es)` blocking internet gateway detach

the usual cause is that Kubernetes-created ALBs still have:

- ENIs in the public subnets
- public IP mappings
- target groups
- security groups

attached to the VPC.

That is a teardown-order problem, not a Terraform syntax problem.

Terraform manages the EKS cluster and VPC. The AWS Load Balancer Controller manages the ALBs created from `Ingress` resources. Those resources must be unwound before Terraform deletes the underlying network.

## Post-Destroy Verification

After Terraform completes, verify cleanup in AWS:

1. `Amazon EKS -> Clusters`
2. `EC2 -> Load balancers`

Expected post-destroy state:

- `pulpit-v2-dev-eks` no longer appears in the EKS cluster list
- the `k8s-...` ALBs no longer appear in the load balancer list

## Commands Summary

```bash
kubectl get ingress -A
kubectl delete ingress --all -A

aws elbv2 describe-load-balancers --region us-east-1
aws elbv2 describe-target-groups --region us-east-1

VPC_ID=$(terraform -chdir=terraform output -raw vpc_id)
aws ec2 describe-network-interfaces --region us-east-1 --filters Name=vpc-id,Values="${VPC_ID}"

terraform -chdir=terraform destroy -var-file=environments/dev/dev.tfvars
```

## Post-Session Notes

Record:

- session date
- deployment duration
- teardown duration
- failed components and fixes
- screenshots still missing
- estimated cost exposure
- follow-up engineering tasks

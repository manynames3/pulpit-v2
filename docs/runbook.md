# Pulpit V2 Runbook

## Purpose

This runbook documents the minimum operational flow for a short-lived portfolio deployment of Pulpit V2:

- bootstrap the EKS environment
- install shared platform components
- verify tenant applications and screenshots
- tear everything down without leaving billable AWS resources behind

The cluster profile in this repo is intentionally demo-oriented. The environment should not be left running after screenshots and verification are complete.

## Demo-day sequence

1. `terraform apply` the dev profile
2. run the platform bootstrap scripts
3. verify AWS, `kubectl`, ArgoCD, Prometheus, and Grafana state
4. capture screenshots
5. remove controller-created cloud resources from Kubernetes
6. run `terraform destroy`
7. verify the cluster and ALBs are gone

## Shared platform bootstrap

The platform bootstrap order is documented in [`../scripts/platform/README.md`](../scripts/platform/README.md).

At a minimum, a healthy session should show:

- two Ready worker nodes
- ArgoCD applications in `Synced / Healthy`
- tenant `ExternalSecret` objects in `SecretSynced / Ready=True`
- Prometheus targets in `UP`
- a working Cloudflare Pages frontend path returning archive results

## Pre-teardown checklist

Before running `terraform destroy`, complete these steps:

1. Capture the remaining screenshots you want to keep.
2. Confirm the frontend, ArgoCD, and observability pages are no longer needed.
3. Remove Kubernetes resources that create AWS resources outside Terraform.
4. Wait for the AWS Load Balancer Controller to delete its ALBs and target groups.
5. Verify the VPC no longer has ALB-owned dependencies.

The critical point is step 3. The ALBs in this environment are created by Kubernetes `Ingress` objects through the AWS Load Balancer Controller. Terraform did not create those ALBs directly, so Terraform cannot cleanly delete the VPC while they still exist.

## Proper teardown order

### 1. Remove ingress-driven tenant resources

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

### 2. Wait for AWS Load Balancer Controller cleanup

Poll until the `k8s-...` ALBs are gone:

```bash
aws elbv2 describe-load-balancers --region us-east-1
aws elbv2 describe-target-groups --region us-east-1
```

The safe state is:

- no tenant ALBs remain
- no tenant target groups remain

### 3. Verify no VPC dependencies remain

The first failed destroy on May 11, 2026 happened because ALB-created ENIs, public IP mappings, target groups, and security groups still existed in the VPC after the EKS cluster had already been removed.

Check for leftover ENIs in the VPC:

```bash
aws ec2 describe-network-interfaces \
  --region us-east-1 \
  --filters Name=vpc-id,Values=vpc-025711caee3a89b53
```

Check for leftover non-default security groups if destroy fails again:

```bash
aws ec2 describe-security-groups \
  --region us-east-1 \
  --filters Name=vpc-id,Values=vpc-025711caee3a89b53
```

If ALB-related ENIs or security groups still exist, wait longer or delete the orphaned ALBs first. Do not rerun `terraform destroy` until the VPC is clear.

### 4. Destroy the Terraform-managed stack

Run destroy from the Terraform directory:

```bash
cd /tmp/pulpit-v2-work/terraform
terraform destroy -var-file=environments/dev/dev.tfvars
```

Capture a screenshot of:

- the destroy command
- the final `Destroy complete!` line
- the resource count summary

## Failure mode: why destroy can fail

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

## Post-destroy verification

After Terraform completes, verify cleanup in AWS:

1. `Amazon EKS -> Clusters`
2. `EC2 -> Load balancers`

Expected post-destroy state:

- `pulpit-v2-dev-eks` no longer appears in the EKS cluster list
- the two `k8s-...` ALBs no longer appear in the load balancer list

## Commands summary

```bash
kubectl get ingress -A
kubectl delete ingress --all -A

aws elbv2 describe-load-balancers --region us-east-1
aws elbv2 describe-target-groups --region us-east-1
aws ec2 describe-network-interfaces --region us-east-1 --filters Name=vpc-id,Values=vpc-025711caee3a89b53

cd /tmp/pulpit-v2-work/terraform
terraform destroy -var-file=environments/dev/dev.tfvars
```

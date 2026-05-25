# Teardown

## Summary

Teardown is part of the platform design. The EKS demo environment should not be left running after evidence capture because the cluster, worker nodes, and load balancers can exceed the low-idle cost guardrail.

## Teardown Order

Use this order to reduce orphaned AWS resources:

1. Capture final screenshots, logs, and notes.
2. Delete ArgoCD applications or disable sync for tenant apps.
3. Delete Kubernetes Ingress resources and wait for ALB deletion.
4. Delete tenant workloads and namespaces.
5. Uninstall cluster add-ons if they were installed manually.
6. Run Terraform destroy.
7. Verify no AWS resources remain.

## Kubernetes Cleanup

Inspect before deletion:

```bash
kubectl get applications -n argocd
kubectl get ingress -A
kubectl get svc -A
kubectl get pods -A
```

Delete or sync-delete ArgoCD apps:

```bash
kubectl delete application -n argocd bethel-atlanta demo-church tenant-policies shared-namespaces
kubectl delete application -n argocd pulpit-v2-root
```

If application names differ, list them first and delete the actual names.

Wait for ingress cleanup:

```bash
kubectl get ingress -A
```

Do not continue until AWS load balancers created by Kubernetes ingress are gone or actively deleting.

## Terraform Destroy

```bash
terraform -chdir=terraform plan -destroy -var-file=environments/dev/dev.tfvars
terraform -chdir=terraform destroy -var-file=environments/dev/dev.tfvars
```

## AWS Verification

Check for leftovers:

```bash
aws eks describe-cluster --region us-east-1 --name pulpit-v2-dev-eks
aws elbv2 describe-load-balancers --region us-east-1
aws ec2 describe-nat-gateways --region us-east-1
aws ec2 describe-volumes --region us-east-1 --filters Name=status,Values=available
aws ecr describe-repositories --region us-east-1
```

Expected result after full cleanup:

- EKS cluster not found
- no Pulpit V2 ALBs
- no Pulpit V2 target groups
- no unexpected NAT gateways
- no unattached EBS volumes from the demo
- no ECR repositories unless intentionally retained

## Common Teardown Issues

| Symptom | Likely cause | Fix |
|---|---|---|
| Terraform destroy hangs on VPC | load balancer, ENI, or security group still exists | delete ingress and wait for controller cleanup |
| ALB remains after cluster deletion | ingress was removed after controller disappeared | delete ALB manually and record the incident |
| Namespace stuck terminating | finalizer remains on custom resource | inspect finalizers and delete dependent CRs first |
| ECR repository blocks destroy | images remain and force delete disabled | empty repo or enable force delete for demo |
| ExternalSecret stuck | CRD or operator removed before CR cleanup | delete ExternalSecret resources before removing the operator |

## Teardown Evidence

Capture at least:

- `terraform destroy` success
- EKS cluster absence
- ALB absence
- notes about any manual cleanup

Add the evidence to [deployment-evidence.md](deployment-evidence.md) after a real demo run.

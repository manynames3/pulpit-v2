# Platform Bootstrap Scripts

These scripts turn the V2 repo into a repeatable demo-day deployment sequence after the EKS cluster exists.

## Order

1. `scripts/platform/00-update-kubeconfig.sh`
2. `scripts/platform/10-install-aws-load-balancer-controller.sh`
3. `scripts/platform/30-install-external-secrets.sh`
4. `scripts/platform/40-install-kube-prometheus-stack.sh`
5. `scripts/platform/20-install-argocd.sh`
6. `scripts/platform/50-post-install-health-checks.sh`

`scripts/platform/90-bootstrap-demo-platform.sh` runs the same sequence end to end.

## Teardown

Do not destroy the Terraform stack immediately after the cluster is still serving tenant `Ingress` objects.

The safe order is:

1. delete ingress-driven resources first
2. wait for the AWS Load Balancer Controller to delete its ALBs and target groups
3. verify the VPC no longer has ALB-owned ENIs or security groups
4. run `terraform destroy`

The full teardown procedure is documented in [`../../docs/runbook.md`](../../docs/runbook.md).

## Assumptions

- `terraform apply` for the V2 cluster has already completed.
- AWS credentials are active for the target account.
- The current repo state is the one you want ArgoCD to sync.
- The cluster is the cost-controlled demo profile: public worker nodes, no NAT, short-lived runtime.

## Required local tools

- `aws`
- `kubectl`
- `helm`
- `terraform`
- `eksctl`
- `curl`

## Environment variables

Optional overrides:

- `AWS_REGION`
- `CLUSTER_NAME`
- `TERRAFORM_DIR`
- `ALB_CONTROLLER_CHART_VERSION`
- `ARGOCD_CHART_VERSION`
- `EXTERNAL_SECRETS_CHART_VERSION`
- `KUBE_PROMETHEUS_STACK_CHART_VERSION`

If unset, the scripts derive defaults from `terraform/environments/dev/dev.tfvars` and Terraform outputs.

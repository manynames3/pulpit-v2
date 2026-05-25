# Cost Model

## Summary

Pulpit V2 is designed as a short-lived EKS demo environment. It is not intended to idle continuously. The live Cloudflare Pages frontend and V1 serverless backend preserve the low-idle product path while the EKS platform migration is validated.

## Cost Guardrail

Do not deploy or leave running AWS resources expected to cost more than `$0.50/day` without explicit approval.

The default EKS demo profile exceeds that guardrail when running:

- EKS control plane hourly cost
- two `t3.medium` worker nodes
- internet-facing ALB
- possible EBS volumes
- possible CloudWatch/metrics/log retention

Use the EKS environment only during approved demo windows and tear it down the same day.

## Current Cost Controls

Implemented in repo:

- NAT gateways are disabled by default.
- Node group defaults are explicit and small: two `t3.medium` nodes.
- ECR repositories use `force_delete` for demo cleanup.
- Cluster deployment is separated under `terraform/` so it can be planned and destroyed as a unit.
- Teardown docs include ALB cleanup sequencing.
- Cloudflare Pages hosts the static frontend separately from the EKS demo environment.
- The current live query path bridges to V1's pay-per-use serverless backend during migration.

## Cost Risks

| Risk | Why it matters | Control |
|---|---|---|
| EKS left running | control plane and nodes accrue hourly cost | same-day teardown |
| ALB orphaned | load balancer can remain after cluster deletion | delete ingress/apps before Terraform destroy |
| NAT gateway enabled | can dominate demo cost | default `enable_nat_gateway = false` |
| ECR images accumulate | storage cost grows over time | lifecycle policy should be added next |
| CloudWatch logs retained | logs can grow quietly | set retention when log groups are introduced |
| Bedrock usage | model calls are usage-based | add app-layer token/cost metrics after migration |

## Demo Deployment Profile

Default dev values:

- region: `us-east-1`
- availability zones: `us-east-1a`, `us-east-1b`
- NAT gateway: disabled
- node subnet type: public
- node instance type: `t3.medium`
- desired node count: `2`

This profile is for deployment evidence capture, not continuous service.

## Production Cost Improvements

If this became a longer-lived platform, the next cost work would be:

- private nodes with VPC endpoints where cost-effective
- managed node group right-sizing or Karpenter
- ECR lifecycle policies
- CloudWatch log retention
- AWS Budgets alarms
- per-tenant Bedrock cost attribution
- scale-to-zero alternatives for non-critical services
- explicit S3 lifecycle policies for raw and processed sermon artifacts

## Teardown Verification

After teardown, verify:

- EKS cluster is gone
- managed node group is gone
- ALB is gone
- target groups are gone
- ECR repositories are removed if the demo account should be clean
- no NAT gateways exist
- no unexpected EBS volumes remain

# Security Model

## Summary

Pulpit V2 is a platform scaffold, so the security model is partly implemented and partly documented as the required next layer. The repo already avoids plaintext application secrets, models workload identity, scopes CI publishing permissions, and separates tenants through Kubernetes resources.

## Least-Privilege IAM

Implemented:

- `terraform/modules/iam` creates a GitHub Actions OIDC provider and role.
- The ECR push policy is scoped to repositories under the project prefix.
- EKS IRSA is enabled through the EKS Terraform module.
- Helm service accounts can be annotated with tenant-specific IAM role ARNs.
- V2 CI should use GitHub OIDC, not the legacy V1 access-key helper under `scripts/create-ci-user.sh`.

Not yet implemented:

- final tenant workload IAM roles for S3, DynamoDB, Bedrock, or SSM access
- AWS Load Balancer Controller IAM policy provisioning
- External Secrets Operator IAM policy provisioning

Expected production direction:

- separate IAM roles per tenant and per workload type
- no wildcard data-plane permissions except where AWS APIs require them
- condition keys and resource-prefix restrictions for SSM, S3, and DynamoDB

## Secrets Management

Implemented:

- Helm renders ExternalSecret resources when enabled.
- Tenant values reference SSM Parameter Store paths instead of storing secret values.
- Pods can consume generated Kubernetes Secrets through `envFrom`.
- `.gitignore` excludes `.env`, local tfvars, Terraform state, Python cache, and generated packages.

Not yet implemented:

- ClusterSecretStore installation
- tenant SSM parameter bootstrap
- rotation process documentation for each secret type

## Network Boundaries

Implemented:

- Terraform creates public and private subnets.
- NAT gateway creation is disabled by default for cost control.
- Kubernetes ingress is modeled through ALB annotations.
- Services are ClusterIP behind ingress.

Current demo tradeoff:

- Worker nodes default to public subnets for early bring-up and cost control.
- Production should prefer private worker nodes, restricted control plane access, VPC endpoints, and no direct node exposure.

## Authentication And Authorization

Current V2 state:

- FastAPI service stubs do not enforce user authentication.
- The live V2 frontend currently relies on the V1 Cognito/API Gateway boundary for query/catalog calls.
- The V2 API edge does not verify JWTs yet.

Expected V2 target:

- Cognito issues user tokens.
- `api-service` verifies JWT signatures against Cognito JWKS.
- tenant and admin authorization are checked before query or settings actions.
- service-to-AWS access uses IRSA instead of static AWS keys.

## Migration Boundary

The V1 bridge is a security boundary as well as a product boundary. Until V2 `api-service` verifies Cognito JWTs and enforces tenant authorization, V2 should not accept production query traffic directly through the EKS API edge.

## Audit Logging

Current state:

- Kubernetes and AWS audit logging are documented as an operational requirement.
- V1 reference Terraform includes CloudTrail and optional GuardDuty patterns.
- V2 Terraform does not yet create a CloudTrail module.

Expected production direction:

- enable CloudTrail for AWS API activity
- retain ALB access logs if public ingress remains
- log application request IDs, tenant IDs, and authorization outcomes without logging tokens or prompts that should remain private
- store administrative setting changes in an auditable durable store

## Monitoring And Alerts

Implemented:

- services expose Prometheus metrics endpoints
- Helm renders ServiceMonitor resources
- Helm renders starter PrometheusRule alerts for service scrape failure, query latency, and ingest failures
- Grafana dashboard starter exists under `helm/observability`

Limitations:

- the alert expressions are starters and need verification against the final Prometheus labels
- no paging or incident routing is configured

## Failure Modes

Expected failure modes include:

- image pull failures from ECR
- ExternalSecret sync failure because SSM paths or IAM permissions are missing
- ALB ingress not provisioning because the controller or subnet tags are wrong
- ArgoCD app drift or failed sync
- ingest job failure or repeated retries
- query latency spikes after real retrieval logic is migrated

Each failure mode is covered at a high level in [runbook.md](runbook.md).

## Rollback And Recovery

Current model:

- ArgoCD provides Git-based rollback for Kubernetes manifests and Helm values.
- ECR images are published with SHA tags by the workflow, even though Helm defaults still use `latest`.
- Terraform changes should be reviewed through plan output before apply.

Production improvements:

- deploy immutable image tags or digests through Helm values
- add database/index backup and restore procedures after V1 data migration
- add smoke tests after ArgoCD sync

## Blast-Radius Considerations

Implemented:

- tenant namespaces
- tenant-specific Helm values
- ResourceQuota and LimitRange manifests
- per-tenant SSM parameter paths in Helm values
- IRSA role annotation shape per tenant

Not yet implemented:

- tenant-specific AWS data resources in V2 Terraform
- network policies
- separate tenant IAM roles with final permissions

## Validated Versus Demo-Only

Validated locally or through repo structure:

- service endpoints and metrics through unit tests
- Helm chart structure
- Terraform module structure
- CI workflows for validation and builds

Demo-only or pending:

- live EKS add-on installation
- real workload IAM policies
- real Cognito enforcement in V2
- production audit logging
- production incident routing

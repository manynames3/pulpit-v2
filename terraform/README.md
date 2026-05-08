# V2 Terraform

This directory now holds the first real Phase 1 scaffold for Pulpit V2:

- VPC and subnets
- ECR repositories for the three services
- EKS cluster wrapper with managed node groups and IRSA enabled
- optional GitHub Actions OIDC role scaffold

The defaults are intentionally demo-friendly:

- region defaults to `us-east-1`
- service images are expected in ECR later
- NAT is disabled by default to avoid surprise cost
- nodes default to public subnets for early bring-up

For a more production-like network later, switch node placement to private subnets and enable NAT or VPC endpoints.

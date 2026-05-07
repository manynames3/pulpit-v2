# Architecture Decision Records

ADRs for Pulpit V2 will be added here as the EKS architecture is implemented.

Initial planned decisions:

- separate V2 repo and deployment from V1
- EKS over ECS/Lambda for portfolio and platform goals
- GitOps with ArgoCD
- IRSA over static AWS credentials
- Prometheus/Grafana for tenant-aware observability

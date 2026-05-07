# Pulpit V2 Architecture

## Overview

Pulpit V2 re-architects the original serverless sermon search system into a multi-tenant Kubernetes platform. The goal is not to replace V1 immediately in production. The goal is to demonstrate platform engineering, observability, GitOps, and containerized service design on a real workload.

## C4-style Container Diagram

```mermaid
flowchart LR
    user["Church member or staff"]
    alb["AWS ALB Ingress"]
    api["api-service\nFastAPI"]
    query["query-service\nFastAPI"]
    ingest["ingest-service\nCronJob / Job"]
    cognito["Amazon Cognito"]
    bedrock["Amazon Bedrock\nClaude / Titan"]
    dynamodb["Amazon DynamoDB"]
    s3["Amazon S3"]
    prometheus["Prometheus"]
    grafana["Grafana"]
    argocd["ArgoCD"]
    ecr["Amazon ECR"]
    github["GitHub Actions"]
    youtube["YouTube captions"]

    user --> alb
    alb --> api
    api --> cognito
    api --> query
    query --> dynamodb
    query --> s3
    query --> bedrock
    ingest --> youtube
    ingest --> bedrock
    ingest --> dynamodb
    ingest --> s3
    query --> prometheus
    api --> prometheus
    ingest --> prometheus
    prometheus --> grafana
    github --> ecr
    github --> argocd
    argocd --> api
    argocd --> query
    argocd --> ingest
```

## Namespaces

Expected tenant model:

- `bethel-atlanta`
- `demo-church`

Shared platform namespaces:

- `argocd`
- `observability`
- `external-secrets`
- `ingress-system`

## Runtime Model

### Query path

1. User sends a request through ALB ingress.
2. `api-service` authenticates and resolves tenant context.
3. `query-service` performs retrieval against indexed sermon data.
4. `query-service` calls Bedrock for answer generation.
5. Metrics are exported for latency, request volume, and model usage.

### Ingest path

1. `ingest-service` runs on schedule per tenant.
2. It fetches YouTube captions, transforms sermons, and generates embeddings.
3. Indexed data is written to DynamoDB and/or S3 depending on the storage design used during implementation.
4. Metrics are emitted for ingest count, failures, and cost attribution.

## Key Decisions

- Use a **separate repo** from V1 to keep the platform story isolated.
- Use **EKS** because the portfolio goal is Kubernetes/DevOps credibility, not lowest cost.
- Keep **tenant visibility** first-class in dashboards and metrics.
- Treat **V1 code as migration reference**, not production dependency.

## Constraints

- EKS should be easy to destroy after demos to control cost.
- Bedrock cost attribution must happen at the app layer, not by Kubernetes namespace alone.
- Kubernetes features must map to real business reasoning, not resume padding.

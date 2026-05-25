# Tradeoffs

## EKS Instead Of Lambda Or ECS

The lowest-cost version of Pulpit is closer to V1: static frontend, Lambda, DynamoDB/S3, and Bedrock. V2 intentionally uses EKS because the goal is to demonstrate Kubernetes, GitOps, Helm, IRSA, External Secrets, and observability as platform work.

Consequence:

- stronger platform engineering signal
- higher operational complexity and cost
- strict teardown discipline required

## Public Nodes And No NAT By Default

The Terraform dev profile defaults to public worker nodes and no NAT gateway. This keeps an early demo deploy simpler and avoids a NAT gateway cost surprise.

Consequence:

- cheaper and easier demo bring-up
- weaker production posture than private nodes
- production should move workers private and use VPC endpoints or controlled NAT

## ArgoCD App-Of-Apps

ArgoCD app-of-apps is used to model shared resources, tenant policies, and tenant workload apps separately.

Consequence:

- clear GitOps ownership boundary
- easy reviewer path through manifests
- requires ArgoCD installation and operational knowledge

## External Secrets And SSM

The Helm chart renders ExternalSecret resources that point to SSM parameter paths. This avoids committing runtime secrets.

Consequence:

- clean secret boundary in Git
- requires External Secrets Operator, SecretStore/ClusterSecretStore, and IAM setup
- demo cannot be fully live until those cluster pieces exist

## IRSA Over Static AWS Keys

Workloads are modeled with service account annotations for IAM roles.

Consequence:

- avoids static AWS keys in pods
- supports tenant-specific AWS permissions
- requires final IAM roles and trust policies before production use

## Mutable Image Tags For Demo

Helm defaults currently use `latest`, while CI can publish commit SHA tags.

Consequence:

- convenient for early demo iteration
- weaker rollback and provenance story
- production should use SHA tags or immutable digests in tenant values

## Platform Before Product Migration

The V2 service code is intentionally minimal. It proves the deployment and operations surface first, then leaves V1 query and ingest migration as the next major implementation step.

Consequence:

- platform can be validated early
- avoids mixing infrastructure maturity work with application rewrite work
- product behavior is preserved through the V1 bridge until migration is done

## Bridge To V1 During Migration

The live V2 frontend calls V1 API Gateway for query and catalog behavior.

Consequence:

- cited answers and source cards keep working while the platform migrates
- reviewers can see a real migration boundary instead of a rewrite claim
- V2 must not claim full replacement until retrieval, auth, cache, audit, and source-card behavior are implemented

## Ingestion Outside EKS Unless OAuth Captions API Exists

V1 showed that YouTube transcript scraping from AWS IP ranges is unreliable. Running the same scraper in EKS would not change the IP-range problem.

Consequence:

- V2 `ingest-service` should focus on validation, enrichment, embedding, and index publication
- caption collection should remain local/church-network or move to official YouTube captions API with channel-owner OAuth
- the platform story stays honest about operational constraints

## Starter Observability

The repo includes metrics endpoints, ServiceMonitors, PrometheusRules, and a Grafana dashboard starter.

Consequence:

- observability hooks are present from the beginning
- alerts and dashboards need live cluster verification
- real domain metrics depend on query and ingest migration

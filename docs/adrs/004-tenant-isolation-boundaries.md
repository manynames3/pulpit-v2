# ADR 004: Tenant Isolation Through Kubernetes And AWS Boundaries

**Status:** Accepted

## Context

Pulpit V2 is intended to model a multi-tenant platform. Tenants need separation at the Kubernetes resource layer and eventually at the AWS data/identity layer.

## Decision

Model tenant isolation with namespaces, ResourceQuotas, LimitRanges, per-tenant Helm values, External Secrets, and IRSA-ready service accounts.

## Consequences

- Tenant boundaries are visible in Git, ArgoCD, kubectl, Prometheus, and Grafana.
- Resource limits reduce blast radius inside the cluster.
- SSM parameter paths and IAM role annotations prepare for tenant-scoped AWS access.
- Final production readiness still requires tenant-specific IAM policies, SSM path restrictions, auth checks, and possibly NetworkPolicies.

# ADR 003: Use EKS Despite Higher Cost For Platform Proof

**Status:** Accepted

## Context

The lowest-cost runtime for Pulpit is the V1 serverless architecture. The V2 goal is different: demonstrate EKS, Kubernetes, Helm, ArgoCD, tenant isolation, External Secrets, IRSA, Prometheus, Grafana, and teardown discipline.

## Decision

Use Amazon EKS for the V2 platform work sample, but treat the cluster as a short-lived demo environment unless a separate cost approval exists.

## Consequences

- The repo provides stronger AWS/Kubernetes/platform evidence.
- The architecture costs more than V1 if left running.
- NAT is disabled by default, the demo node group is small, and teardown is documented as part of operations.
- V1 remains the low-idle product path during migration.

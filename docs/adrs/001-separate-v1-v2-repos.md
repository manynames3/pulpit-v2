# ADR 001: Keep V1 And V2 As Separate Repos

**Status:** Accepted

## Context

Pulpit V1 is a working serverless AWS product. It contains the proven query path, retrieval quality work, ingestion scripts, frontend, Terraform modules, and deployment discipline. Pulpit V2 has a different goal: prove the Kubernetes/EKS platform migration path.

## Decision

Keep V1 and V2 as separate repositories. Retain V1-derived folders in V2 only as migration reference until the corresponding V2 services are implemented.

## Consequences

- V1 remains stable while V2 platform work evolves.
- Hiring managers can distinguish product proof from platform migration proof.
- Some temporary duplication is acceptable.
- V2 must document migration boundaries clearly so reviewers do not mistake scaffolding for a completed replacement.

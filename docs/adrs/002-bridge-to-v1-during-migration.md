# ADR 002: Bridge To V1 During Migration

**Status:** Accepted

## Context

The V1 query backend already supports authenticated cited answers, hybrid retrieval, source cards, caching, and audit logging. Replacing it too early would risk losing product quality while the EKS platform is still being built.

## Decision

Keep the live V2 frontend bridged to V1 API Gateway query/catalog endpoints until V2 `api-service` and `query-service` pass cutover criteria.

## Consequences

- V2 can demonstrate platform maturity without regressing user-facing answer quality.
- The bridge is a temporary migration boundary, not the final architecture.
- Documentation must state that V2 has not fully replaced V1.
- Cutover requires retrieval, auth, source-card, cache, audit, and rollback validation.

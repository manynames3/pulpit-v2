# ADR 006: Keep YouTube Transcript Collection Outside EKS Unless OAuth Captions API Is Implemented

**Status:** Accepted

## Context

V1 discovered that YouTube transcript scraping is unreliable from AWS IP ranges. Moving the same scraping behavior into EKS would still run from cloud IP ranges and would not solve the underlying problem. The official YouTube captions API requires OAuth consent from the channel owner; an API key alone is not enough for caption download access.

## Decision

Treat V2 `ingest-service` as the indexing, enrichment, embedding, validation, and tenant handoff layer until either trusted local/church-network caption collection remains the source or official YouTube captions API with OAuth is implemented.

## Consequences

- V2 does not overclaim that EKS solves ingestion.
- The platform still owns validation, enrichment, indexing, and publication.
- A local/church-network runner can remain part of the operational model.
- If channel-owner OAuth is approved, caption collection can move into a managed service path later.

# ADR 005: Preserve V1 Retrieval Quality Before V2 Cutover

**Status:** Accepted

## Context

V1 includes significant retrieval quality work: hybrid semantic and lexical ranking, bilingual query planning, synonym crosswalks, Korean morphology handling, reranking, source snippets, cache invalidation, and a golden-query evaluation harness.

## Decision

Do not remove the V1 query bridge until V2 preserves the important V1 retrieval behaviors and passes a V2 retrieval contract.

## Consequences

- V2 platform migration is tied to product-quality acceptance, not just infrastructure completion.
- `services/query-service/eval/retrieval-golden.json` records the minimum behavior contract.
- V2 cutover requires cited source cards, bilingual retrieval, Korean morphology behavior, and index-aware cache invalidation.
- This slows migration but avoids a polished Kubernetes deployment with weaker search quality.

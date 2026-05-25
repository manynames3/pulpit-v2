# Retrieval Quality Migration

## Purpose

Pulpit V2 should not be judged only by whether it can run containers on EKS. It must preserve the retrieval behavior that Pulpit V1 already proved. This document defines what V1 contributes, what V2 currently preserves through the bridge, and what must be true before the V1 query backend can be removed.

## What V1 Already Proves

V1 is a working serverless AWS product. Its retrieval path includes:

- S3-backed sermon JSON and a chunked `transcripts/index.json`.
- Bedrock Titan embeddings generated at ingest time.
- hybrid retrieval with semantic scoring plus BM25-style lexical scoring.
- bilingual query planning for Korean and English questions.
- synonym/crosswalk handling through `lambda/query/retrieval_synonyms.json`.
- Korean token normalization and morphology-aware matching.
- per-subquery retrieval with candidate union.
- neighbor chunk expansion within the same sermon.
- reranking before answer generation.
- source snippets and source cards in query responses.
- answer, planner, and reranker cache entries in DynamoDB.
- answer-cache invalidation tied to retrieval version, config version, synonym version, language, and the S3 index marker.
- a golden-query evaluation harness under `eval/retrieval-golden.json` and `scripts/evaluate_retrieval.py`.

The retrieval quality work is documented in V1 at `docs/retrieval-quality-iterations.md`.

## Quality Behaviors To Preserve

| Behavior | Why it matters |
|---|---|
| Hybrid retrieval | Sermon queries often depend on exact Bible terms, Korean phrases, names, and concepts that embeddings alone can miss. |
| Bilingual query planning | Users ask in Korean, English, or mixed language while the archive content may be mostly Korean. |
| BM25-style lexical scoring | Rare archive-specific terms such as `구름기둥`, `고고학`, or `자만` need stronger ranking behavior. |
| Synonym handling | English concepts such as `money`, `death`, or `cloud column` need Korean retrieval paths. |
| Korean morphology handling | Queries like `고고학` should match related forms such as `고고학자`, `발굴`, `유물`, and `유적`. |
| Source snippets | Reviewers and church users need to see why a sermon was returned, not just a generated answer. |
| Reranking | The answer model should receive the strongest evidence chunks, not only broad keyword matches. |
| Cache invalidation | New sermon indexes must not keep serving stale answer-cache results. |
| Golden-query evaluation | Retrieval changes need repeatable checks instead of ad hoc manual impressions. |

## What V2 Currently Preserves Through The Bridge

The live V2 frontend currently calls the V1 API Gateway query/catalog endpoints. Because of that bridge, the user-facing answer path still benefits from V1's:

- Cognito/API Gateway boundary.
- Lambda retrieval implementation.
- Bedrock answer generation.
- S3 index and DynamoDB cache/audit tables.
- cited answers and source cards.
- known retrieval improvements and cache invalidation behavior.

This bridge is a migration boundary, not the final V2 architecture.

## What Must Move Into `services/query-service`

Before cutover, V2 `query-service` needs:

- tenant-aware index loading.
- bilingual query planning.
- packaged synonym/crosswalk configuration.
- semantic embedding support.
- BM25-style lexical scoring across title, topics, scripture, metadata, and chunk text.
- Korean token normalization and morphology-aware matching.
- per-subquery retrieval with candidate union and deduplication.
- neighbor chunk expansion.
- reranking.
- source snippets and source-card payload compatibility.
- cache and audit behavior equivalent to V1 or explicitly redesigned.
- index-marker-aware cache invalidation.
- golden-query evaluation support.
- no-result handling that is honest and user-safe.

## Acceptance Criteria Before Removing The V1 Bridge

V2 can remove the V1 query bridge only when:

1. V2 passes the retrieval contract under `services/query-service/eval/retrieval-golden.json`.
2. The V2 response shape supports cited answers, source snippets, and source cards used by the frontend.
3. Korean natural-language queries still retrieve relevant Korean sermon evidence.
4. English-to-Korean concept queries still work for known crosswalk terms.
5. Korean morphology cases do not regress.
6. cache keys or equivalent invalidation include the active index version.
7. V2 records query/audit events without logging secrets or tokens.
8. tenant context is enforced before index selection.
9. no-result responses are clear and do not fabricate sermon evidence.
10. rollback to the V1 bridge remains possible during the first cutover.

## Initial Golden Query Categories

The V2 contract fixture includes examples from V1:

- Korean natural-language query: `최근에 목사님이 자만에 대한 설교를 했나요`
- English-to-Korean concept query: `cloud column`
- English-to-Korean topic query: `money`
- Korean morphology case: `고고학`
- source-card expectation: `death`

The fixture is intentionally a contract, not a benchmark. It defines behaviors V2 must preserve before replacing V1.

## Migration Risks

If V2 only copies infrastructure without preserving retrieval behavior:

- the EKS version may look more sophisticated while answering worse than V1.
- Korean and English users may lose important cross-language search behavior.
- source cards may become weaker or disappear.
- cached answers may become stale after index changes.
- ingestion and retrieval quality regressions may be hidden by a successful Kubernetes deployment.
- hiring managers reviewing the repo may see platform mechanics without product-quality ownership.

The platform migration is credible only if it protects the retrieval quality learned in V1.

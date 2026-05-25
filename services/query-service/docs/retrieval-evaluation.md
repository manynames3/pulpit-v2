# Query Service Retrieval Evaluation

## Purpose

This directory records the retrieval behavior V2 must preserve before replacing the V1 query backend. It is intentionally lightweight: the current V2 `query-service` does not implement V1 retrieval yet, so the test fixture is a contract, not a ranking benchmark.

## Source Of The Contract

The examples come from Pulpit V1's retrieval quality work:

- hybrid retrieval with semantic and BM25-style lexical ranking
- bilingual query planning
- Korean-English synonym/crosswalk handling
- Korean morphology-aware matching
- source snippets and source cards
- golden-query evaluation through `eval/retrieval-golden.json`

## Fixture

File:

```text
services/query-service/eval/retrieval-golden.json
```

The fixture covers:

- Korean natural-language query
- English-to-Korean concept query
- English-to-Korean topic query
- Korean morphology case
- source-snippet/source-card expectation

## Current Test

File:

```text
services/query-service/tests/test_retrieval_contract.py
```

The test verifies the contract shape so future migration work has a stable target. It does not claim retrieval is implemented in V2.

## Cutover Use

Before removing the V1 bridge, replace or extend the contract test with a real evaluator that runs V2 retrieval against an exported tenant index and checks:

- expected sermon IDs where known
- expected Korean/English terms in matched snippets
- source card payload completeness
- no-result behavior
- cache/index-version behavior

The V1 bridge should remain until those checks pass.

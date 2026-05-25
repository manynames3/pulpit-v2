# V1 Reference And Migration Notes

Pulpit V1 is the working serverless product. V2 should preserve V1's product behavior while moving the platform runtime toward EKS/GitOps.

The following folders are here as migration reference:

- `frontend/`
- `frontend-alternative/`
- `lambda/`
- `modules/`
- `scripts/`

Expected migration targets:

- `lambda/query` -> `services/query-service`
- `scripts/ingest-local.py` and `scripts/rebuild_index.py` -> `services/ingest-service`
- Terraform patterns from `modules/` -> `terraform/modules/`

V1 lessons that should shape V2:

- keep hybrid retrieval, bilingual query planning, BM25-style lexical scoring, synonyms, reranking, source snippets, and cache invalidation behavior
- keep golden-query evaluation before cutover
- do not assume EKS fixes YouTube caption scraping from AWS IP ranges
- use local/church-network caption collection or official YouTube captions API with OAuth before treating ingestion as fully cloud-native

Do not treat the V1 folders as the final V2 architecture. They exist so V2 can reuse proven logic instead of rewriting everything from a blank repo.

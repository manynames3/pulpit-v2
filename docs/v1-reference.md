# V1 Reference Notes

This repository is seeded from Pulpit V1. The following folders are here as migration reference:

- `frontend/`
- `frontend-alternative/`
- `lambda/`
- `modules/`
- `scripts/`

Expected migration targets:

- `lambda/query` -> `services/query-service`
- `scripts/ingest-local.py` and `scripts/rebuild_index.py` -> `services/ingest-service`
- Terraform patterns from `modules/` -> `terraform/modules/`

Do not treat the V1 folders as the final V2 architecture. They exist so V2 can reuse proven logic instead of rewriting everything from a blank repo.


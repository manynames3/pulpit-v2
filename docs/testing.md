# Testing And Validation

## Summary

The repo currently has service-level unit tests, Helm validation paths, Terraform validation paths, Docker build checks, and static YAML parsing in CI. It does not yet have integration tests against a live cluster or end-to-end product tests.

## Local Test Commands

Install shared test tooling:

```bash
python -m pip install --upgrade pip
python -m pip install pytest httpx
```

Run service tests:

```bash
python -m pip install -r services/api-service/requirements.txt
PYTHONPATH=services/api-service pytest services/api-service/tests -q

python -m pip install -r services/query-service/requirements.txt
PYTHONPATH=services/query-service pytest services/query-service/tests -q

python -m pip install -r services/ingest-service/requirements.txt
PYTHONPATH=services/ingest-service pytest services/ingest-service/tests -q
```

## What The Tests Cover

Current tests cover:

- `/healthz` responses
- `/readyz` responses
- `/metrics` endpoint availability
- expected Prometheus metric names
- retrieval migration contract fixture shape

They do not cover:

- auth
- tenant routing
- real query behavior
- ingest idempotency
- Bedrock/S3/DynamoDB integrations

## Retrieval Migration Contract

Files:

- `services/query-service/eval/retrieval-golden.json`
- `services/query-service/docs/retrieval-evaluation.md`
- `services/query-service/tests/test_retrieval_contract.py`

Run:

```bash
PYTHONPATH=services/query-service pytest services/query-service/tests/test_retrieval_contract.py -q
```

This test does not claim V2 retrieval is implemented. It pins the minimum V1 behaviors V2 must preserve before removing the bridge:

- Korean natural-language query behavior
- English-to-Korean concept mapping
- Korean morphology handling
- source snippet/source card expectations

## Helm Validation

```bash
helm lint helm/pulpit --values helm/pulpit/values-bethel-atlanta.yaml
helm lint helm/pulpit --values helm/pulpit/values-demo-church.yaml

helm template bethel-atlanta helm/pulpit \
  --namespace bethel-atlanta \
  --values helm/pulpit/values-bethel-atlanta.yaml

helm template demo-church helm/pulpit \
  --namespace demo-church \
  --values helm/pulpit/values-demo-church.yaml
```

These checks validate chart structure and rendering. They do not prove the cluster add-ons or CRDs are installed.

## Static Manifest Validation

The platform CI parses YAML under `manifests/`. A local equivalent:

```bash
python - <<'PY'
from pathlib import Path
import yaml

for path in sorted(Path("manifests").rglob("*.yaml")):
    with path.open("r", encoding="utf-8") as handle:
        list(yaml.safe_load_all(handle))
PY
```

## Terraform Validation

```bash
terraform -chdir=terraform init -backend=false
terraform fmt -check -recursive terraform
terraform -chdir=terraform validate
```

Optional security/lint tools:

- Checkov is referenced by the platform CI.
- `.tflint.hcl` exists for TFLint, but the CI workflow does not currently run TFLint.

## Docker Build Checks

```bash
docker build -t pulpit-v2/api-service:local services/api-service
docker build -t pulpit-v2/query-service:local services/query-service
docker build -t pulpit-v2/ingest-service:local services/ingest-service
```

The GitHub `Build Images` workflow runs this pattern for all three services.

## Deployment Smoke Tests

After a live EKS deployment:

```bash
kubectl get pods -A
kubectl get ingress -A
kubectl get hpa -A
kubectl get cronjob -A
kubectl get servicemonitor -A
kubectl get prometheusrule -A
```

Then verify an API service through port-forward or ALB:

```bash
curl http://localhost:8080/healthz
curl http://localhost:8080/readyz
curl http://localhost:8080/metrics
```

## CI Workflows

`.github/workflows/ci.yml`:

- Terraform format check
- Terraform init/validate
- Checkov Terraform scan
- Helm lint/template
- static YAML parse for manifests

`.github/workflows/build-push.yml`:

- Python tests for each service
- Docker build for each service
- optional ECR push gated by repository variables

## Remaining Test Gaps

- no integration tests against EKS
- no ArgoCD sync test
- no External Secrets sync test
- no real query or ingest behavior tests
- no auth/JWT tests in V2 service code
- no frontend automated test
- no load or resilience tests

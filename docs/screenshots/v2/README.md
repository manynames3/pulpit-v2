# V2 Screenshot Index

This folder contains the curated screenshots from the May 11, 2026 live deployment session.

## Folders

- `frontend/`
  - Cloudflare Pages login and signed-in application flow
- `aws/`
  - EKS cluster, node group, and ALB captures from the AWS Console
- `kubectl/`
  - terminal captures of cluster state, secrets, and Prometheus rules
- `argocd/`
  - GitOps application overview and resource trees
- `observability/`
  - Grafana dashboards and Prometheus target/rule/alert views

## Primary narrative

Use [`../../deployment-walkthrough.md`](../../deployment-walkthrough.md) for the public-facing deployment walkthrough. This directory is the supporting image inventory behind that page.

## Intentionally omitted

The original screenshot batch included duplicates, intermediate auth troubleshooting screens, and dashboards with no useful data. Those were left out on purpose so the final set stays focused on working infrastructure and runtime state.

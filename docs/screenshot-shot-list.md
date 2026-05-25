# Pulpit V2 Screenshot Shot List

Use this checklist during the live deployment session.

## Must-Have Shots

- [ ] `eks-cluster-overview.png`
- [ ] `managed-node-group.png`
- [ ] `kubectl-get-nodes.png`
- [ ] `kubectl-get-pods-all-namespaces.png`
- [ ] `kubectl-get-ingress-all-namespaces.png`
- [ ] `kubectl-get-hpa-all-namespaces.png`
- [ ] `kubectl-get-cronjobs-all-namespaces.png`
- [ ] `argocd-applications-overview.png`
- [ ] `argocd-bethel-atlanta-app.png`
- [ ] `grafana-pulpit-overview-dashboard.png`
- [ ] `prometheus-targets.png`
- [ ] `externalsecret-bethel-atlanta.png`
- [ ] `serviceaccount-irsa-annotation.png`
- [ ] `ecr-repositories.png`
- [ ] `live-app-query-result.png`
- [ ] `terraform-destroy-success.png`

## Nice-to-Have Shots

- [ ] `terraform-apply-success.png`
- [ ] `kubectl-get-namespaces.png`
- [ ] `argocd-root-application.png`
- [ ] `grafana-latency-panel.png`
- [ ] `grafana-ingest-health-panel.png`
- [ ] `iam-workload-role.png`
- [ ] `resourcequota-bethel-atlanta.png`
- [ ] `limitrange-demo-church.png`

## Screenshot Hygiene Rules

- Keep resource names visible.
- Keep region visible when it helps credibility.
- Do not expose secrets or tokens.
- Crop dead space, not evidence.
- Prefer one strong screenshot per concept over many repetitive ones.
- Leave timestamps visible when possible.

## Suggested Documentation Placement

- Infrastructure screenshots -> `docs/deployment-evidence.md`
- ArgoCD and GitOps screenshots -> `docs/deployment-evidence.md`
- Observability screenshots -> `docs/deployment-evidence.md`
- Security and secret-handling screenshots -> `docs/deployment-evidence.md`
- Teardown screenshot -> `docs/deployment-evidence.md`

## Session Notes

Record after the demo:

- Session date:
- Deployment duration:
- Destroy duration:
- Missing screenshots:
- Follow-up fixes:

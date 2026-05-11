#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_base_tools

VALUES_FILE="${ARGOCD_VALUES_FILE:-${SCRIPT_DIR}/values/argocd-demo.yaml}"
CHART_VERSION="${ARGOCD_CHART_VERSION:-}"

log "Installing ArgoCD"
helm repo add argo https://argoproj.github.io/argo-helm >/dev/null
helm repo update argo >/dev/null

HELM_ARGS=(
  upgrade --install argocd argo/argo-cd
  --namespace argocd
  --create-namespace
  --values "${VALUES_FILE}"
  --wait
  --timeout 10m
)

if [[ -n "${CHART_VERSION}" ]]; then
  HELM_ARGS+=(--version "${CHART_VERSION}")
fi

helm "${HELM_ARGS[@]}"

log "Applying ArgoCD project and root application"
kubectl apply -f "${REPO_ROOT}/manifests/argocd/project.yaml"
kubectl apply -f "${REPO_ROOT}/manifests/argocd/root-application.yaml"

log "ArgoCD server rollout status"
kubectl rollout status deployment/argocd-server -n argocd --timeout=5m

log "ArgoCD initial admin password"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode
printf '\n'
